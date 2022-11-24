import 'package:system_proxy_resolver/system_proxy_resolver.dart';
import 'package:system_proxy_resolver/system_proxy_resolver_platform_interface.dart';

class SystemProxyResolver {
  SystemProxySettings getSystemProxySettings() {
    return SystemProxyResolverPlatform.instance.getSystemProxySettings();
  }

  Future<List<Proxy>> getProxyForUrl(String url) {
    return SystemProxyResolverPlatform.instance.getProxyForUrl(url);
  }
}
