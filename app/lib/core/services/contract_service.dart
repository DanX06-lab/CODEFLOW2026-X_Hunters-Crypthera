import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';
import 'wallet_service.dart';
import '../constants/contract_abi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reown_appkit/reown_appkit.dart';

class ContractService {
  static final ContractService _instance = ContractService._internal();
  factory ContractService() => _instance;
  ContractService._internal();

  final WalletService _walletService = WalletService();

  DeployedContract get _contract {
    final contractAbi = VaultContractConfig.jsonAbi;
    final contractAddr = EthereumAddress.fromHex(VaultContractConfig.contractAddress);
    return DeployedContract(
      ContractAbi.fromJson(contractAbi, 'CryptheraVault'),
      contractAddr,
    );
  }

  // DUAL-MODE EXECUTION
  // Returns transaction hash (mock or real)
  Future<String> sendContractTransaction(
    String functionName,
    List<dynamic> args, {
    EtherAmount? value,
  }) async {
    final privateKey = _walletService.currentPrivateKey;
    final address = _walletService.currentAddress;

    if (address == null || address.isEmpty) {
      throw Exception("No wallet connected.");
    }

    // REAL REOWN/WALETCONNECT MODE
    final modal = _walletService.appKitModal;
    if (modal != null && modal.isConnected && modal.session != null) {
      if (kDebugMode) print("ContractService: Running in REAL REOWN/WALETCONNECT MODE");
      final session = modal.session!;
      final contractFunction = _contract.function(functionName);
      final dataHex = '0x' + contractFunction.encodeCall(args).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final valueHex = value != null ? '0x' + value.getInWei.toRadixString(16) : '0x0';

      final tx = {
        'from': address,
        'to': _contract.address.hexEip55,
        'data': dataHex,
        'value': valueHex,
      };

      try {
        final result = await modal.request(
          topic: session.topic!,
          chainId: 'eip155:11155111', // Sepolia Chain ID
          request: SessionRequestParams(
            method: 'eth_sendTransaction',
            params: [tx],
          ),
        );
        return result.toString();
      } catch (e) {
        if (kDebugMode) print("Reown transaction failed: $e");
        rethrow;
      }
    }

    // SIMULATION MODE (Fallback if no private key is stored, and no active Reown session exists)
    if (privateKey == null || privateKey.isEmpty) {
      if (kDebugMode) print("ContractService: Running in SIMULATION MODE");
      await Future.delayed(const Duration(seconds: 2));
      return "0xsimulated${List.generate(50, (_) => '0123456789abcdef'[DateTime.now().microsecond % 16]).join()}";
    }

    // REAL LOCAL PRIVATE KEY BLOCKCHAIN MODE
    if (kDebugMode) print("ContractService: Running in REAL SEPOLIA MODE");
    final credentials = EthPrivateKey.fromHex(privateKey);
    final contractFunction = _contract.function(functionName);

    try {
      final transaction = Transaction.callContract(
        contract: _contract,
        function: contractFunction,
        parameters: args,
        value: value,
      );

      final txHash = await _walletService.client.sendTransaction(
        credentials,
        transaction,
        chainId: 11155111, // Sepolia Chain ID
      );

      return txHash;
    } catch (e) {
      if (kDebugMode) print("Real transaction failed: $e");
      rethrow;
    }
  }

  // DEPOSIT FUNDS
  Future<String> depositFunds(double etherAmount) async {
    final privateKey = _walletService.currentPrivateKey;
    final address = _walletService.currentAddress;

    if (address != null && address.isNotEmpty) {
      if (privateKey == null || privateKey.isEmpty) {
        // Save simulation balance
        final prefs = await SharedPreferences.getInstance();
        final currentSimBal = prefs.getDouble('sim_balance_$address') ?? 0.0;
        await prefs.setDouble('sim_balance_$address', currentSimBal + etherAmount);
        
        // Deduct from wallet balance
        final currentWalletBal = prefs.getDouble('sim_wallet_balance_$address') ?? 2.5;
        await prefs.setDouble('sim_wallet_balance_$address', currentWalletBal - etherAmount);
      }
    }

    final amountInWei = BigInt.from(etherAmount * 1000000000000000000);
    return await sendContractTransaction(
      "deposit",
      [],
      value: EtherAmount.fromBigInt(EtherUnit.wei, amountInWei),
    );
  }

  // SET BENEFICIARIES
  Future<String> setBeneficiaries(
    List<String> addresses,
    List<int> allocations,
  ) async {
    final parsedAddresses = addresses.map((addr) => EthereumAddress.fromHex(addr)).toList();
    final parsedAllocations = allocations.map((alloc) => BigInt.from(alloc)).toList();

    return await sendContractTransaction(
      "setBeneficiaries",
      [parsedAddresses, parsedAllocations],
    );
  }

  // SIMULATE INACTIVITY
  Future<String> simulateInactivity() async {
    return await sendContractTransaction("simulateInactivity", []);
  }

  // RESET INACTIVITY
  Future<String> resetInactivity() async {
    return await sendContractTransaction("resetInactivity", []);
  }

  // CLAIM FUNDS
  Future<String> claimFunds() async {
    final privateKey = _walletService.currentPrivateKey;
    final address = _walletService.currentAddress;
    if (address != null && address.isNotEmpty) {
      if (privateKey == null || privateKey.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('sim_balance_$address', 0.0);
      }
    }
    return await sendContractTransaction("claimFunds", []);
  }

  // VIEW: VAULT BALANCE
  Future<double> getVaultBalance() async {
    final address = _walletService.currentAddress;
    if (address == null || address.isEmpty) {
      return 0.0;
    }

    if (_walletService.currentPrivateKey == null || _walletService.currentPrivateKey!.isEmpty) {
      // Load simulation balance
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('sim_balance_$address') ?? 0.0;
    }

    try {
      final contractFunction = _contract.function("getVaultBalance");
      final response = await _walletService.client.call(
        contract: _contract,
        function: contractFunction,
        params: [],
      );
      if (response.isNotEmpty) {
        final wei = response.first as BigInt;
        return wei / BigInt.from(1000000000000000000);
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) print("Failed to get contract balance: $e");
      return 0.0;
    }
  }

  // VIEW: IS INACTIVE
  Future<bool> isInactive() async {
    final address = _walletService.currentAddress;
    if (address == null || address.isEmpty || _walletService.currentPrivateKey == null || _walletService.currentPrivateKey!.isEmpty) {
      return false;
    }

    try {
      final contractFunction = _contract.function("isInactive");
      final response = await _walletService.client.call(
        contract: _contract,
        function: contractFunction,
        params: [],
      );
      if (response.isNotEmpty) {
        return response.first as bool;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("Failed to query isInactive: $e");
      return false;
    }
  }
}
