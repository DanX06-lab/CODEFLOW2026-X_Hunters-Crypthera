import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // loopback address to host machine from Android Emulator
  final String _endpointUrl = "http://10.0.2.2:5000/chat";

  Future<String> getResponse(String question) async {
    final cleanQuestion = question.trim().toLowerCase();
    
    try {
      if (kDebugMode) print("AiService: Querying Flask backend: $_endpointUrl");
      
      final response = await http.post(
        Uri.parse(_endpointUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": question}),
      ).timeout(const Duration(seconds: 4)); // Fail fast to use local backup

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] as String? ?? "Received invalid response from AI service.";
      } else {
        if (kDebugMode) print("Flask backend returned error status: ${response.statusCode}");
        return _getFallbackResponse(cleanQuestion);
      }
    } catch (e) {
      if (kDebugMode) print("Flask connection failed ($e). Using local fallback engine.");
      return _getFallbackResponse(cleanQuestion);
    }
  }

  String _getFallbackResponse(String query) {
    if (query.contains("secure") || query.contains("security") || query.contains("safe") || query.contains("hack")) {
      return """
Crypthera Vault Security:
1. Non-Custodial: Crypthera does not store your private keys. You are in full control.
2. Smart Contract Locks: Vault assets are locked in an audited EVM smart contract on Sepolia.
3. Decoupled Recovery: Inheritance claims are only possible after inactivity is mathematically verified.
""";
    }
    
    if (query.contains("inactivity") || query.contains("timer") || query.contains("trigger") || query.contains("protocol")) {
      return """
Crypthera Inactivity System:
The vault tracks your check-ins and transactions. If no activity is detected for the timer duration (default 90 days), the vault goes into Warning Mode. If no owner response occurs within the warning window, the contract unlocks beneficiary claims.
""";
    }

    if (query.contains("beneficiary") || query.contains("allocation") || query.contains("split") || query.contains("heir")) {
      return """
Managing Beneficiaries:
You can assign multiple beneficiaries using their public EVM wallet addresses and allocating a percentage share (e.g. 40%, 30%). The smart contract enforces that the total sum of all allocations cannot exceed 100%. You can add or remove beneficiaries at any time.
""";
    }

    if (query.contains("claim") || query.contains("inheritance") || query.contains("recover") || query.contains("withdraw")) {
      return """
Claiming Inherited Crypto:
1. If the owner's vault is flagged as Inactive, the claim terminal unlocks.
2. Go to the Claim Screen from the Vault tab.
3. Input your registered beneficiary wallet address and click Search.
4. The system locates the vault and lets you trigger the 'claimFunds' contract transaction to transfer your allocated share directly to your wallet.
""";
    }

    if (query.contains("swap") || query.contains("smart swap") || query.contains("stablecoin") || query.contains("usdc")) {
      return """
Smart Swap Feature:
Smart Swap is Crypthera's volatility protection protocol. During extreme market crashes, the AI system suggests swapping volatile assets (e.g., ETH, SOL) in your vault into stablecoins (e.g., USDC) to shield your legacy assets from depreciation.
""";
    }

    if (query.contains("briefing") || query.contains("daily") || query.contains("price") || query.contains("market")) {
      return """
Market Briefing Offline:
I cannot fetch live CoinGecko prices while the Flask backend is offline. Please start the chatbot service in the 'crypthera_chatbot' folder (`npm start` or `python app.py`) to access live price statistics, fear & greed indices, and crash simulations.
""";
    }

    // Default general explanation
    return """
I am your Crypthera Guardian AI. I can help explain:
- Vault Security & Non-Custodial Architecture
- Inactivity Protocols & Simulation
- Beneficiary Allocations
- Claiming Inherited Crypto
- Smart Swap Market Protection

Start the Flask backend in `crypthera_chatbot/` for live price lookups, daily briefings, and news analyses!
""";
  }
}
