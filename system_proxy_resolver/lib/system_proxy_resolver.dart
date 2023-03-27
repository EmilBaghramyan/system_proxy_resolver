import 'package:system_proxy_resolver/src/ensure_implemented_stub.dart'
    if (dart.library.ui) 'package:system_proxy_resolver/src/ensure_implemented_ui.dart'
    if (dart.library.ffi) 'package:system_proxy_resolver/src/ensure_implemented_ffi.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';

export 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart'
    hide SystemProxyResolverPlatform;

class SystemProxyResolver {
  SystemProxyResolver() {
    ensureImplementedOnce();
  }

  SystemProxySettings getSystemProxySettings() {
    return SystemProxyResolverPlatform.instance.getSystemProxySettings();
  }

  Future<List<Proxy>> getProxyForUrl(Uri url) {
    return SystemProxyResolverPlatform.instance.getProxyForUrl(url);
  }
}
