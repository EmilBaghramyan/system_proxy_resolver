import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_platform_interface/unimplemented_system_proxy_resolver.dart';

abstract class SystemProxyResolverPlatform extends PlatformInterface {
  /// Constructs a SystemProxyResolverPlatform.
  SystemProxyResolverPlatform() : super(token: _token);

  static final Object _token = Object();

  static SystemProxyResolverPlatform _instance = UnimplementedSystemProxyResolver();

  /// The default instance of [SystemProxyResolverPlatform] to use.
  ///
  /// Defaults to [FfiSystemProxyResolver].
  static SystemProxyResolverPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SystemProxyResolverPlatform] when
  /// they register themselves.
  static set instance(SystemProxyResolverPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  SystemProxySettings getSystemProxySettings() {
    throw UnimplementedError('getSystemProxySettings() has not been implemented.');
  }

  Future<List<Proxy>> getProxyForUrl(Uri url) {
    throw UnimplementedError('getProxyForUrl() has not been implemented.');
  }
}
