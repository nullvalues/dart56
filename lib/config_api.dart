import 'package:meta/meta.dart';
import 'src/config_validator.dart';

class Bootstrap {
  static Map<String, dynamic>? _config;
  static bool _initialized = false;

  /// Gets the current configuration. The returned map is deeply immutable.
  static Map<String, dynamic> get apiConfig {
    if (!_initialized) {
      _initializeConfig();
    }
    return _deeplyImmutableCopy(_config!);
  }

  static void _initializeConfig() {
    final defaultConfig = {
      "bX": {
        "removeChars": "OILoil",
        "prependSeparator": "-",
        "prependDefaultChar": "X",
        "subdomainChar": ".",
        "seqStartValue": "A0"
      }
    };

    ConfigValidator.validateConfig(defaultConfig);
    _config = defaultConfig;
    _initialized = true;
  }

  /// Updates the configuration with custom values. This should only be called
  /// before any other operations are performed.
  static void updateConfig(Map<String, dynamic> newConfig) {
    if (_initialized) {
      throw StateError('Cannot update configuration after initialization');
    }
    ConfigValidator.validateConfig(newConfig);
    _config = newConfig;
    _initialized = true;
  }

  /// Creates a deeply immutable copy of a map
  static Map<String, dynamic> _deeplyImmutableCopy(Map<String, dynamic> map) {
    final copiedMap = Map<String, dynamic>.from(map);
    for (final key in copiedMap.keys) {
      if (copiedMap[key] is Map) {
        copiedMap[key] = Map<String, dynamic>.unmodifiable(
            copiedMap[key] as Map<String, dynamic>);
      }
    }
    return Map<String, dynamic>.unmodifiable(copiedMap);
  }

  /// For testing purposes only - resets the configuration state
  @visibleForTesting
  static void reset() {
    _initialized = false;
    _config = null;
  }
}
