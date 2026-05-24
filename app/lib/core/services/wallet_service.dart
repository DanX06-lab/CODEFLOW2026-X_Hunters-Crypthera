import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reown_appkit/reown_appkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'web3_provider_stub.dart'
    if (dart.library.js) 'web3_provider_web.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // Sepolia Public RPC Endpoint
  final String _rpcUrl = "https://ethereum-sepolia-rpc.publicnode.com";
  
  late Web3Client _web3client;
  final _secureStorage = const FlutterSecureStorage();
  
  String? _cachedAddress;
  String? _cachedPrivateKey;
  ReownAppKitModal? _appKitModal;

  bool get isConnected => _cachedAddress != null && _cachedAddress!.isNotEmpty;
  String? get currentAddress => _cachedAddress;
  String? get currentPrivateKey => _cachedPrivateKey;
  ReownAppKitModal? get appKitModal => _appKitModal;

  Future<String?> connectViaReown(BuildContext context) async {
    try {
      if (_appKitModal == null) {
        final appKit = await ReownAppKit.createInstance(
          projectId: 'c683481e5f7996f74938aa58c755855c', // User's configured project ID
          metadata: const PairingMetadata(
            name: 'Crypthera',
            description: 'Secure AI-Powered Crypto inheritance wallet',
            url: 'https://crypthera.app/',
            icons: ['https://crypthera.app/logo.png'],
            redirect: Redirect(
              native: 'crypthera://',
            ),
          ),
        );

        if (!context.mounted) return null;

        _appKitModal = ReownAppKitModal(
          context: context,
          appKit: appKit,
          optionalNamespaces: {
            'eip155': RequiredNamespace(
              chains: ['eip155:11155111'], // Sepolia Testnet
              methods: const [
                'eth_sendTransaction',
                'eth_signTransaction',
                'eth_sign',
                'personal_sign',
                'eth_signTypedData',
              ],
              events: const ['chainChanged', 'accountsChanged'],
            ),
          },
        );

        await _appKitModal!.init();
      }

      await _appKitModal!.openModalView();

      final session = _appKitModal!.session;
      if (session != null) {
        final address = session.getAddress('eip155');
        if (address != null && address.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          _cachedAddress = address;
          _cachedPrivateKey = ""; // Managed externally by Reown
          await prefs.setString('wallet_address', address);
          await _secureStorage.delete(key: 'wallet_private_key');
          return address;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Reown Wallet Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wallet Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<String?> checkMetaMaskInstalledAndConnect(BuildContext context) async {
    // Skip native package check on Web
    if (kIsWeb) {
      return connectViaReown(context);
    }

    final Uri metamaskUri = Uri.parse("metamask://");
    final Uri storeUri = Uri.parse(
      defaultTargetPlatform == TargetPlatform.iOS
          ? "https://apps.apple.com/us/app/metamask-blockchain-wallet/id1438144200"
          : "https://play.google.com/store/apps/details?id=io.metamask",
    );

    try {
      final bool canOpenMetaMask = await canLaunchUrl(metamaskUri);

      if (!context.mounted) return null;

      if (canOpenMetaMask) {
        return connectViaReown(context);
      } else {
        _showInstallDialog(context, storeUri);
        return null;
      }
    } catch (e) {
      if (!context.mounted) return null;
      _showInstallDialog(context, storeUri);
      return null;
    }
  }

  void _showInstallDialog(BuildContext context, Uri storeUri) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1F26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF2E303D)),
          ),
          title: const Text(
            "MetaMask Required",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Crypthera uses MetaMask to connect your wallet securely. Please install MetaMask to continue.",
            style: TextStyle(color: Color(0xFF9E9EAE)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF9E9EAE)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await launchUrl(
                  storeUri,
                  mode: LaunchMode.externalApplication,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Install MetaMask",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> init() async {
    _web3client = Web3Client(_rpcUrl, http.Client());
    final prefs = await SharedPreferences.getInstance();
    _cachedAddress = prefs.getString('wallet_address');
    
    // Migration check: If the private key was previously stored in shared preferences, move it to secure storage
    if (prefs.containsKey('wallet_private_key')) {
      final oldKey = prefs.getString('wallet_private_key');
      if (oldKey != null && oldKey.isNotEmpty) {
        await _secureStorage.write(key: 'wallet_private_key', value: oldKey);
      }
      await prefs.remove('wallet_private_key');
    }
    
    _cachedPrivateKey = await _secureStorage.read(key: 'wallet_private_key');
  }

  // CONNECT WALLET (REAL EVM, METAMASK, OR SEPM CONTRACT GENERATION)
  Future<String> connectWallet({
    String? importPrivateKey, 
    bool isDevSandbox = false,
    String? watchAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (isDevSandbox) {
      // Hidden developer simulation mode
      const mockAddress = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F";
      _cachedAddress = mockAddress;
      _cachedPrivateKey = "";
      await prefs.setString('wallet_address', mockAddress);
      await _secureStorage.delete(key: 'wallet_private_key');
      return mockAddress;
    }

    if (watchAddress != null && watchAddress.trim().isNotEmpty) {
      final cleanAddr = watchAddress.trim();
      if (cleanAddr.length == 42 && cleanAddr.startsWith("0x")) {
        _cachedAddress = cleanAddr;
        _cachedPrivateKey = "";
        await prefs.setString('wallet_address', cleanAddr);
        await _secureStorage.delete(key: 'wallet_private_key');
        return cleanAddr;
      } else {
        throw Exception("Invalid Ethereum address format.");
      }
    }

    // Web MetaMask Extension connection
    if (kIsWeb && importPrivateKey == null) {
      try {
        final address = await Web3Provider.connectMetaMask();
        _cachedAddress = address;
        _cachedPrivateKey = ""; // Managed externally by browser extension
        await prefs.setString('wallet_address', address);
        await _secureStorage.delete(key: 'wallet_private_key');
        return address;
      } catch (e) {
        throw Exception("MetaMask connection failed: ${e.toString()}");
      }
    }

    EthPrivateKey credentials;
    if (importPrivateKey != null && importPrivateKey.trim().isNotEmpty) {
      try {
        String cleanKey = importPrivateKey.trim();
        if (cleanKey.startsWith("0x")) {
          cleanKey = cleanKey.substring(2);
        }
        credentials = EthPrivateKey.fromHex(cleanKey);
      } catch (e) {
        throw Exception("Invalid private key format. Must be 64 hex characters.");
      }
    } else {
      // Generate a fresh key pair
      final rng = Random.secure();
      credentials = EthPrivateKey.createRandom(rng);
    }

    final address = credentials.address.hexEip55;
    final privateKeyHex = credentials.privateKey.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

    _cachedAddress = address;
    _cachedPrivateKey = privateKeyHex;

    await prefs.setString('wallet_address', address);
    await _secureStorage.write(key: 'wallet_private_key', value: privateKeyHex);

    return address;
  }

  // DISCONNECT WALLET
  Future<void> disconnectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet_address');
    await _secureStorage.delete(key: 'wallet_private_key');
    _cachedAddress = null;
    _cachedPrivateKey = null;

    if (_appKitModal != null && _appKitModal!.isConnected) {
      try {
        await _appKitModal!.disconnect();
      } catch (e) {
        if (kDebugMode) print("Error disconnecting Reown session: $e");
      }
    }
  }

  // GET ETH BALANCE FROM SEPOLIA OR LOCAL SIMULATED BALANCES
  Future<EtherAmount> getBalance(String address) async {
    try {
      if (address.isEmpty || address.startsWith("0x71C7")) {
        // Return simulated wallet balance
        final prefs = await SharedPreferences.getInstance();
        final simWalletBal = prefs.getDouble('sim_wallet_balance_$address') ?? 2.5; // Start with 2.5 mock ETH
        return EtherAmount.fromBigInt(
          EtherUnit.wei,
          BigInt.from(simWalletBal * 1000000000000000000),
        );
      }
      final ethereumAddress = EthereumAddress.fromHex(address);
      return await _web3client.getBalance(ethereumAddress);
    } catch (e) {
      if (kDebugMode) print("Error fetching balance: $e");
      return EtherAmount.zero();
    }
  }

  // GET BALANCE AS FORMATTED STRING
  Future<String> getBalanceFormatted(String address) async {
    final rawBalance = await getBalance(address);
    final ethValue = rawBalance.getValueInUnit(EtherUnit.ether);
    return "${ethValue.toStringAsFixed(4)} ETH";
  }

  // ESTIMATE PEER-TO-PEER GAS FEE
  Future<EtherAmount> estimateGasFee({
    required String recipientAddress,
    required double amount,
  }) async {
    try {
      final sender = currentAddress;
      if (sender == null || sender.isEmpty) {
        return EtherAmount.zero();
      }

      // In simulation mode, return mock gas fee
      final privateKey = _cachedPrivateKey;
      if (privateKey == null || privateKey.isEmpty) {
        return EtherAmount.fromBigInt(EtherUnit.gwei, BigInt.from(21000 * 10)); // 21000 gas * 10 gwei
      }

      final senderAddr = EthereumAddress.fromHex(sender);
      final recipient = EthereumAddress.fromHex(recipientAddress.trim());
      final value = EtherAmount.fromBigInt(
        EtherUnit.wei,
        BigInt.from(amount * 1000000000000000000),
      );

      final gasPrice = await _web3client.getGasPrice();
      final gasLimit = await _web3client.estimateGas(
        sender: senderAddr,
        to: recipient,
        value: value,
      );

      return EtherAmount.fromBigInt(EtherUnit.wei, gasPrice.getInWei * gasLimit);
    } catch (e) {
      if (kDebugMode) print("Gas estimation failed, using fallback: $e");
      return EtherAmount.fromBigInt(EtherUnit.gwei, BigInt.from(21000 * 20));
    }
  }

  // SEND ETHER TO PEER ADDRESS
  Future<String> sendETH({
    required String recipientAddress,
    required double amount,
  }) async {
    final privateKey = _cachedPrivateKey;
    if (privateKey == null || privateKey.isEmpty) {
      // Simulation mode transfer: subtract from mock balance
      final address = _cachedAddress;
      if (address != null && address.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final simWalletBal = prefs.getDouble('sim_wallet_balance_$address') ?? 2.5;
        await prefs.setDouble('sim_wallet_balance_$address', max(0.0, simWalletBal - amount));
      }
      await Future.delayed(const Duration(seconds: 2));
      return "0xsimulatedTransfer${List.generate(40, (_) => '0123456789abcdef'[Random().nextInt(16)]).join()}";
    }

    final credentials = EthPrivateKey.fromHex(privateKey);
    final recipient = EthereumAddress.fromHex(recipientAddress.trim());
    final value = EtherAmount.fromBigInt(
      EtherUnit.wei,
      BigInt.from(amount * 1000000000000000000),
    );

    final txHash = await _web3client.sendTransaction(
      credentials,
      Transaction(
        to: recipient,
        value: value,
      ),
      chainId: 11155111,
    );
    return txHash;
  }

  Web3Client get client => _web3client;
}
