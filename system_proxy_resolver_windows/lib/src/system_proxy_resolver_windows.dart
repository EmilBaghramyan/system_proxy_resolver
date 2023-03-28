import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_windows/src/common.dart';
import 'package:system_proxy_resolver_windows/src/libs.dart';
import 'package:system_proxy_resolver_windows/src/system_proxy_resolver_windows_dart.dart'
    if (dart.library.ui) 'package:system_proxy_resolver_windows/src/system_proxy_resolver_windows_flutter.dart';
import 'package:system_proxy_resolver_windows/src/utils.dart';
import 'package:system_proxy_resolver_windows/src/winhttp.g.dart';
import 'package:win32/win32.dart';

class SystemProxyResolverWindows extends SystemProxyResolverBase {
  /// Registers this class as the default instance of
  /// [SystemProxyResolverPlatform].
  static void registerWith() {
    SystemProxyResolverPlatform.instance = SystemProxyResolverWindows();
  }

  @override
  SystemProxySettings getSystemProxySettings() {
    return using((arena) {
      final proxyConfig = arena<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG>()..addTo(arena);
      if (winHttpLib.WinHttpGetIEProxyConfigForCurrentUser(proxyConfig) == FALSE) {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }

      final proxies = parseProxies(proxyConfig.ref.lpszProxy.nullIfNullptr?.toDartString() ?? "").toList();
      final proxyBypass = parseProxyBypass(proxyConfig.ref.lpszProxyBypass.nullIfNullptr?.toDartString() ?? "");
      return SystemProxySettings(
        autoDiscoveryEnabled: proxyConfig.ref.fAutoDetect == TRUE,
        autoConfigUrl: proxyConfig.ref.lpszAutoConfigUrl.nullIfNullptr?.toDartString(),
        httpProxy: proxies.firstWhere((e) => e.type == ProxyType.http, orElse: () => Proxy.direct()),
        httpsProxy: proxies.firstWhere((e) => e.type == ProxyType.https, orElse: () => Proxy.direct()),
        ftpProxy: proxies.firstWhere((e) => e.type == ProxyType.ftp, orElse: () => Proxy.direct()),
        socksProxy: proxies.firstWhere((e) => e.type == ProxyType.socks, orElse: () => Proxy.direct()),
        bypassHostnames: proxyBypass.bypassHostnames,
        bypassSimpleHostnames: proxyBypass.bypassSimpleHostnames,
      );
    });
  }
}
