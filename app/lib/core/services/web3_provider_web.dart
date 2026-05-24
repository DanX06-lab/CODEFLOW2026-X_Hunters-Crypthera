// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:async';

class Web3Provider {
  static bool get isSupported => js.context.hasProperty('ethereum');

  static void injectScripts() {
    try {
      final dynamic document = js.context['document'];
      if (document == null) return;
      final dynamic head = document['head'];
      final dynamic script = document.callMethod('createElement', ['script']);
      script['text'] = """
        window.connectMetaMask = async function() {
          try {
            window.metaMaskResult = "pending";
            if (!window.ethereum) {
              window.metaMaskResult = "error:MetaMask not installed";
              return;
            }
            const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
            window.metaMaskResult = "success:" + accounts[0];
          } catch (e) {
            window.metaMaskResult = "error:" + e.toString();
          }
        };
        window.getMetaMaskChainId = async function() {
          try {
            window.metaMaskChainResult = "pending";
            if (!window.ethereum) {
              window.metaMaskChainResult = "error:MetaMask not installed";
              return;
            }
            const chainId = await window.ethereum.request({ method: "eth_chainId" });
            window.metaMaskChainResult = "success:" + chainId;
          } catch (e) {
            window.metaMaskChainResult = "error:" + e.toString();
          }
        };
      """;
      head.callMethod('appendChild', [script]);
    } catch (e) {
      // Ignored on non-web platforms
    }
  }

  static Future<String> connectMetaMask() async {
    if (!isSupported) {
      throw Exception("MetaMask is not installed.");
    }
    
    injectScripts();
    js.context.callMethod('connectMetaMask');
    
    // Poll for the result from JavaScript
    while (js.context['metaMaskResult'] == 'pending') {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    final result = js.context['metaMaskResult']?.toString() ?? "";
    if (result.startsWith("success:")) {
      return result.substring(8);
    } else if (result.startsWith("error:")) {
      throw Exception(result.substring(6));
    } else {
      throw Exception("Connection timed out or failed.");
    }
  }

  static Future<String> getChainId() async {
    if (!isSupported) {
      throw Exception("MetaMask is not installed.");
    }
    
    injectScripts();
    js.context.callMethod('getMetaMaskChainId');
    
    while (js.context['metaMaskChainResult'] == 'pending') {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    final result = js.context['metaMaskChainResult']?.toString() ?? "";
    if (result.startsWith("success:")) {
      return result.substring(8);
    } else if (result.startsWith("error:")) {
      throw Exception(result.substring(6));
    } else {
      throw Exception("Failed to query chain ID.");
    }
  }
}
