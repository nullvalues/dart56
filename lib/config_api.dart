class Bootstrap {

  static Map<String, dynamic> get apiConfig {
    return Bootstrap()._apiConfigObjects;
  }

  final Map<String, dynamic> _apiConfigObjects = {
    "bX": {
      "removeChars": "OILoil",
      "prependSeparator": "-",
      "prependDefaultChar": "X",
      "subdomainChar": ".",
      "seqStartValue": "A0"
    }
  };

}
