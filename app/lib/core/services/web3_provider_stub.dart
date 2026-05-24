class Web3Provider {
  static bool get isSupported => false;

  static Future<String> connectMetaMask() async {
    throw UnimplementedError("MetaMask browser extension is only supported on Web platforms.");
  }

  static Future<String> getChainId() async {
    throw UnimplementedError("Web3 provider not available.");
  }
}
