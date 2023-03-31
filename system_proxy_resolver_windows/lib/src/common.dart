import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_windows/src/proxy_bypass.dart';

Iterable<Proxy> parseProxies(String input) sync* {
  var proxies = input;
  final doubleSlashIndex = proxies.indexOf("//");
  if (doubleSlashIndex > -1) {
    proxies = proxies.substring(doubleSlashIndex + 2);
  }

  if (proxies.isEmpty) return;

  if (!proxies.contains("=")) {
    final proxy = parseProxy(proxies, ProxyType.direct);

    yield proxy.copyWith(type: ProxyType.http);
    yield proxy.copyWith(type: ProxyType.https);
    yield proxy.copyWith(type: ProxyType.ftp);
  } else {
    final semicolonTokens = proxies.split(";");
    for (final semicolonToken in semicolonTokens) {
      final equalsTokens = semicolonToken.split("=");
      var i = 0;
      var proxyType = ProxyType.direct;

      for (final equalsToken in equalsTokens) {
        switch (i++) {
          case 0:
            switch (equalsToken) {
              case "http":
                proxyType = ProxyType.http;
                break;
              case "https":
                proxyType = ProxyType.https;
                break;
              case "ftp":
                proxyType = ProxyType.ftp;
                break;
              case "socks":
                proxyType = ProxyType.socks;
                break;
            }
            break;
          case 1:
            if (proxyType != ProxyType.direct) {
              yield parseProxy(equalsToken, proxyType);
            }
            break;
        }
      }
    }
  }
}

Proxy parseProxy(String proxy, ProxyType type) {
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

ProxyBypass parseProxyBypass(String proxyBypass) {
  final bypassHostnames = <String>[];
  var bypassSimpleHostnames = false;

  if (proxyBypass.isNotEmpty) {
    final tokens = proxyBypass.toLowerCase().split(";");

    for (final token in tokens) {
      if (token == "<local>") {
        bypassSimpleHostnames = true;
      } else {
        bypassHostnames.add(token);
      }
    }
  }

  return ProxyBypass(bypassHostnames: bypassHostnames, bypassSimpleHostnames: bypassSimpleHostnames);
}

Iterable<Proxy> selectProxyForUrl(Uri url, Iterable<Proxy> proxies, ProxyBypass proxyBypass) sync* {
  var shouldBypass = proxyBypass.bypassSimpleHostnames && url.hasSimpleHost;
  shouldBypass = shouldBypass || proxyBypass.bypassHostnames.contains(url.host);
  if (shouldBypass) {
    yield Proxy.direct();
  } else {
    ProxyType? proxyTypeForScheme;
    switch (url.scheme) {
      case "http":
        proxyTypeForScheme = ProxyType.http;
        break;
      case "https":
        proxyTypeForScheme = ProxyType.https;
        break;
    }
    yield* proxies.where((e) => e.type == proxyTypeForScheme || e.type == ProxyType.socks);
  }
}

extension on Uri {
  bool get hasSimpleHost => !host.contains(".");
}
