import 'package:system_proxy_resolver_federated/system_proxy_resolver_federated.dart';
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
