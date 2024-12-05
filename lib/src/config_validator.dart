class ConfigValidationError extends Error {
  final String message;
  ConfigValidationError(this.message);
  
  @override
  String toString() => 'ConfigValidationError: $message';
}

class ConfigValidator {
  static void validateConfig(Map<String, dynamic> config) {
    if (!config.containsKey('bX')) {
      throw ConfigValidationError('Missing required "bX" configuration section');
    }

    final bxConfig = config['bX'];
    if (bxConfig is! Map<String, dynamic>) {
      throw ConfigValidationError('The "bX" configuration must be a Map');
    }

    _validateRequiredString(bxConfig, 'removeChars');
    _validateRequiredString(bxConfig, 'prependSeparator');
    _validateRequiredString(bxConfig, 'prependDefaultChar');
    _validateRequiredString(bxConfig, 'subdomainChar');
    _validateRequiredString(bxConfig, 'seqStartValue');

    // Validate specific constraints
    if (bxConfig['prependSeparator'].length != 1) {
      throw ConfigValidationError('prependSeparator must be exactly one character');
    }

    if (bxConfig['prependDefaultChar'].length != 1) {
      throw ConfigValidationError('prependDefaultChar must be exactly one character');
    }

    if (bxConfig['subdomainChar'].length != 1) {
      throw ConfigValidationError('subdomainChar must be exactly one character');
    }

    // Validate that special characters don't overlap
    final specialChars = {
      bxConfig['prependSeparator'],
      bxConfig['subdomainChar'],
    };

    if (specialChars.length != 2) {
      throw ConfigValidationError(
          'prependSeparator and subdomainChar must be different characters');
    }

    // Validate that special characters are not in removeChars
    final removeChars = bxConfig['removeChars'];
    for (final char in specialChars) {
      if (removeChars.contains(char)) {
        throw ConfigValidationError(
            'Special characters cannot be in removeChars: $char');
      }
    }

    // Validate seqStartValue format (should contain at least one character)
    if (bxConfig['seqStartValue'].isEmpty) {
      throw ConfigValidationError('seqStartValue cannot be empty');
    }
  }

  static void _validateRequiredString(
      Map<String, dynamic> config, String key) {
    if (!config.containsKey(key)) {
      throw ConfigValidationError('Missing required configuration key: $key');
    }
    if (config[key] is! String) {
      throw ConfigValidationError('Configuration key $key must be a string');
    }
  }
}
