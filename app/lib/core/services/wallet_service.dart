import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  // Sepolia Public RPC Endpoint
  final String _rpcUrl = "https://ethereum-sepolia-rpc.publicnode.com";
  
  late Web3Client _web3client;
  String? _cachedAddress;
  String? _cachedPrivateKey;

  bool get isConnected => _cachedAddress != null && _cachedAddress!.isNotEmpty;
  String? get currentAddress => _cachedAddress;
  String? get currentPrivateKey => _cachedPrivateKey;

  Future<void> init() async {
    _web3client = Web3Client(_rpcUrl, http.Client());
    final prefs = await SharedPreferences.getInstance();
    _cachedAddress = prefs.getString('wallet_address');
    _cachedPrivateKey = prefs.getString('wallet_private_key');
  }

  // CONNECT WALLET (SIMULATED OR IN-APP GENERATED)
  Future<String> connectWallet({String? importPrivateKey, bool isSimulated = false}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (isSimulated) {
      // Predefined hardcoded address for quick mock testing
      const mockAddress = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F";
      _cachedAddress = mockAddress;
      _cachedPrivateKey = "";
      await prefs.setString('wallet_address', mockAddress);
      await prefs.remove('wallet_private_key');
      return mockAddress;
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
    await prefs.setString('wallet_private_key', privateKeyHex);

    return address;
  }

  // DISCONNECT WALLET
  Future<void> disconnectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet_address');
    await prefs.remove('wallet_private_key');
    _cachedAddress = null;
    _cachedPrivateKey = null;
  }

  // GET ETH BALANCE FROM SEPOLIA
  Future<EtherAmount> getBalance(String address) async {
    try {
      if (address.isEmpty || address.startsWith("0x71C7")) {
        // Return 0 for simulated/empty addresses
        return EtherAmount.zero();
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

  Web3Client get client => _web3client;
}
