import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_windows/src/libs.dart';
import 'package:system_proxy_resolver_windows/src/utils.dart';
import 'package:system_proxy_resolver_windows/src/winhttp.g.dart';
import 'package:win32/win32.dart';

class SystemProxyResolverWindows extends SystemProxyResolverPlatform {
  /// Registers this class as the default instance of
  /// [SystemProxyResolverPlatform].
  static void registerWith() {
    SystemProxyResolverPlatform.instance = SystemProxyResolverWindows();
  }

  @override
  SystemProxySettings getSystemProxySettings() {
    return using((arena) {
      final proxyConfig = arena<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG>()..addTo(arena);
      if (!winHttpLib.WinHttpGetIEProxyConfigForCurrentUser(proxyConfig)) {
        throw WindowsException(GetLastError());
      }

      var result = _emptySystemProxySettings();
      result = result.copyWith(
        autoDiscoveryEnabled: proxyConfig.ref.fAutoDetect,
        autoConfigUrl: proxyConfig.ref.lpszAutoConfigUrl.nullIfNullptr?.toDartString(),
      );
      result = _parseProxies(proxyConfig.ref.lpszProxy.nullIfNullptr?.toDartString() ?? "", result);
      result = _parseProxyBypass(proxyConfig.ref.lpszProxyBypass.nullIfNullptr?.toDartString() ?? "", result);

      return result;
    });
  }

  static SystemProxySettings _emptySystemProxySettings() => SystemProxySettings(
        autoDiscoveryEnabled: false,
        httpProxy: Proxy.direct(),
        httpsProxy: Proxy.direct(),
        ftpProxy: Proxy.direct(),
        socksProxy: Proxy.direct(),
        bypassHostnames: [],
        bypassSimpleHostnames: false,
      );

  SystemProxySettings _parseProxies(String proxies, SystemProxySettings settings) {
    if (proxies.isEmpty) return settings;

    if (!proxies.contains("=")) {
      final proxy = _parseProxy(proxies, ProxyType.direct);

      return settings.copyWith(
        httpProxy: proxy.copyWith(type: ProxyType.http),
        httpsProxy: proxy.copyWith(type: ProxyType.https),
        ftpProxy: proxy.copyWith(type: ProxyType.ftp),
      );
    }

    var proxySettings = settings;
    final semicolonTokens = proxies.split(";");
    for (final semicolonToken in semicolonTokens) {
      final equalsTokens = semicolonToken.split("=");
      var i = 0;
      var proxyType = ProxyType.direct;
      void Function(Proxy proxy)? assignProxy;

      for (final equalsToken in equalsTokens) {
        switch (i++) {
          case 0:
            switch (equalsToken) {
              case "http":
                proxyType = ProxyType.http;
                assignProxy = (proxy) => proxySettings = proxySettings.copyWith(httpProxy: proxy);
                break;
              case "https":
                proxyType = ProxyType.https;
                assignProxy = (proxy) => proxySettings = proxySettings.copyWith(httpsProxy: proxy);
                break;
              case "ftp":
                proxyType = ProxyType.ftp;
                assignProxy = (proxy) => proxySettings = proxySettings.copyWith(ftpProxy: proxy);
                break;
              case "socks":
                proxyType = ProxyType.socks;
                assignProxy = (proxy) => proxySettings = proxySettings.copyWith(socksProxy: proxy);
                break;
            }
            break;
          case 1:
            if (assignProxy != null) {
              assignProxy(_parseProxy(equalsToken, proxyType));
            }
            break;
        }
      }
    }

    return proxySettings;
  }

  Proxy _parseProxy(String proxy, ProxyType type) {
    final colonIndex = proxy.indexOf(":");

    final String host;
    int port = 0;
    if (colonIndex > 0) {
      host = proxy.substring(0, colonIndex);
      port = int.parse(proxy.substring(colonIndex + 1));
    } else {
      host = proxy;
    }

    return Proxy(type: type, host: host, port: port);
  }

  SystemProxySettings _parseProxyBypass(String proxyBypass, SystemProxySettings settings) {
    if (proxyBypass.isEmpty) return settings;

    final tokens = proxyBypass.split(";");
    var bypassSimpleHostnames = settings.bypassSimpleHostnames;
    final hostnames = <String>[];
    for (final token in tokens) {
      if (token == "<local>") {
        bypassSimpleHostnames = true;
      } else {
        hostnames.add(token);
      }
    }

    return settings.copyWith(bypassHostnames: hostnames, bypassSimpleHostnames: bypassSimpleHostnames);
  }
}
