import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for MOE Commerce package.
class MoeCommerceConfig {
  final String apiUrl;
  final bool enableMultiStore;

  const MoeCommerceConfig({
    required this.apiUrl,
    this.enableMultiStore = false,
  });
}

/// Provider for commerce config.
final commerceConfigProvider = Provider<MoeCommerceConfig>((ref) {
  throw UnimplementedError('MoeCommerce.setup() must be called before use.');
});

/// Setup function — call in main() before runApp().
class MoeCommerce {
  static late MoeCommerceConfig _config;

  static void setup({required MoeCommerceConfig config}) {
    _config = config;
  }

  static MoeCommerceConfig get config => _config;
}
