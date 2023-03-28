import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_windows/src/common.dart';
import 'package:system_proxy_resolver_windows/src/libs.dart';
import 'package:system_proxy_resolver_windows/src/utils.dart';
import 'package:system_proxy_resolver_windows/src/winhttp.g.dart';
import 'package:win32/win32.dart';

class SystemProxyResolverBase extends SystemProxyResolverPlatform {
  static final _sessionHandle = (() {
    return using((arena) {
      final result = winHttpLib.WinHttpOpen(
        "".toLPWSTR(allocator: arena),
        WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY,
        Pointer.fromAddress(WINHTTP_NO_PROXY_NAME),
        Pointer.fromAddress(WINHTTP_NO_PROXY_BYPASS),
        0,
      );
      if (result == nullptr) {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }
      return result;
    });
  })();

  @override
  Future<List<Proxy>> getProxyForUrl(Uri url) {
    return using((arena) async {
      final ieProxyConfig = arena<WINHTTP_CURRENT_USER_IE_PROXY_CONFIG>()..addTo(arena);
      if (winHttpLib.WinHttpGetIEProxyConfigForCurrentUser(ieProxyConfig) == FALSE) {
        throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
      }

      var lpszProxy = ieProxyConfig.ref.lpszProxy;
      var lpszProxyBypass = ieProxyConfig.ref.lpszProxyBypass;

      if (ieProxyConfig.ref.fAutoDetect == TRUE || ieProxyConfig.ref.lpszAutoConfigUrl != nullptr) {
        final autoProxyOptions = arena<WINHTTP_AUTOPROXY_OPTIONS>();
        if (ieProxyConfig.ref.lpszAutoConfigUrl != nullptr) {
          autoProxyOptions.ref.dwFlags = WINHTTP_AUTOPROXY_CONFIG_URL;
          autoProxyOptions.ref.lpszAutoConfigUrl = ieProxyConfig.ref.lpszAutoConfigUrl;
          autoProxyOptions.ref.dwAutoDetectFlags = 0;
        } else if (ieProxyConfig.ref.fAutoDetect == TRUE) {
          autoProxyOptions.ref.dwFlags = WINHTTP_AUTOPROXY_AUTO_DETECT;
          autoProxyOptions.ref.lpszAutoConfigUrl = nullptr;
          autoProxyOptions.ref.dwAutoDetectFlags = WINHTTP_AUTO_DETECT_TYPE_DHCP | WINHTTP_AUTO_DETECT_TYPE_DNS_A;
        }
        autoProxyOptions.ref.fAutoLogonIfChallenged = TRUE;

        final proxyInfo = arena<WINHTTP_PROXY_INFO>();
        arena.onReleaseAll(() {
          GlobalSafeFree(proxyInfo.ref.lpszProxy);
          GlobalSafeFree(proxyInfo.ref.lpszProxyBypass);
        });
        final status = winHttpLib.WinHttpGetProxyForUrl(
          _sessionHandle,
          url.toString().toLPWSTR(allocator: arena),
          autoProxyOptions,
          proxyInfo,
        );

        if (status == TRUE) {
          lpszProxy = proxyInfo.ref.lpszProxy;
          lpszProxyBypass = proxyInfo.ref.lpszProxyBypass;
        } else if (ieProxyConfig.ref.lpszAutoConfigUrl != nullptr) {
          // throw only if auto config url has failed
          throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
        }
      }

      return selectProxyForUrl(
        url,
        parseProxies(lpszProxy.nullIfNullptr?.toDartString() ?? ""),
        parseProxyBypass(lpszProxyBypass.nullIfNullptr?.toDartString() ?? ""),
      ).toList(growable: false);
    });
  }
}
