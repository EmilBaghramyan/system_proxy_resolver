import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:system_proxy_resolver/src/system_proxy_resolver_ffi.dart';
import 'package:system_proxy_resolver/system_proxy_resolver.dart';

abstract class SystemProxyResolverPlatform extends PlatformInterface {
  /// Constructs a SystemProxyResolverPlatform.
  SystemProxyResolverPlatform() : super(token: _token);

  static final Object _token = Object();

  static SystemProxyResolverPlatform _instance = FfiSystemProxyResolver();

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

  Future<List<Proxy>> getProxyForUrl(String url) {
    throw UnimplementedError('getProxyForUrl() has not been implemented.');
  }
}
