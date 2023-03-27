import 'dart:collection';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_windows/src/libs.dart';
import 'package:system_proxy_resolver_windows/src/utils.dart';
import 'package:system_proxy_resolver_windows/src/winhttp.g.dart';
import 'package:win32/win32.dart';

class SystemProxyResolverBase extends SystemProxyResolverPlatform {
  static final _sessionHandle = (() {
    final result = helperLib.initializeWinHttpSession(NativeApi.postCObject.cast());
    if (result == nullptr) {
      throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
    }
    return result;
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

        final resolverPtr = arena<Pointer<Void>>();
        final resolverStatus = winHttpLib.WinHttpCreateProxyResolver(_sessionHandle, resolverPtr);
        if (resolverStatus != ERROR_SUCCESS) {
          throw WindowsException(HRESULT_FROM_WIN32(resolverStatus));
        }
        final resolver = arena.using(resolverPtr.value, winHttpLib.WinHttpCloseHandle);

        final callbackStatus = winHttpLib.WinHttpSetStatusCallback(
          resolver,
          helperLib.winHttpStatusCallback,
          WINHTTP_CALLBACK_FLAG_REQUEST_ERROR | WINHTTP_CALLBACK_FLAG_GETPROXYFORURL_COMPLETE,
          0,
        );
        if (callbackStatus == WINHTTP_INVALID_STATUS_CALLBACK) {
          throw WindowsException(HRESULT_FROM_WIN32(GetLastError()));
        }

        final callbackPort = arena.using<ReceivePort>(ReceivePort(), (p) => p.close());
        final getProxyStatus = winHttpLib.WinHttpGetProxyForUrlEx(
          resolver,
          url.toString().toLPWSTR(allocator: arena),
          autoProxyOptions,
          callbackPort.sendPort.nativePort,
        );
        if (getProxyStatus != ERROR_IO_PENDING) {
          throw WindowsException(HRESULT_FROM_WIN32(getProxyStatus));
        }

        return callbackPort
            .cast<int>()
            .map((address) {
              return using((arena) {
                final result = Pointer<WinHttpStatusCallbackResult>.fromAddress(address);
                arena.onReleaseAll(() => helperLib.freeWinHttpStatusCallbackResult(result));
                return _handleCallbackResult(result, arena);
              });
            })
            .where((event) => event != null)
            .first
            .then((value) => value!);
      }

      print(lpszProxy.nullIfNullptr?.toDartString());
      print(lpszProxyBypass.nullIfNullptr?.toDartString());

      // TODO: implement getProxyForUrl
      return super.getProxyForUrl(url);
    });
  }

  List<Proxy>? _handleCallbackResult(Pointer<WinHttpStatusCallbackResult> result, Arena arena) {
    if (result.ref.dwInternetStatus == WINHTTP_CALLBACK_STATUS_REQUEST_ERROR) {
      final asyncResult = result.ref.lpvStatusInformation.cast<WINHTTP_ASYNC_RESULT>();
      // if (asyncResult.ref.dwResult != API_GET_PROXY_FOR_URL) {}
      throw WindowsException(HRESULT_FROM_WIN32(asyncResult.ref.dwError));
    } else if (result.ref.dwInternetStatus == WINHTTP_CALLBACK_STATUS_GETPROXYFORURL_COMPLETE) {
      final proxyResult = arena<WINHTTP_PROXY_RESULT>();
      final getProxyResultStatus = winHttpLib.WinHttpGetProxyResult(result.ref.hInternet, proxyResult);
      if (getProxyResultStatus != ERROR_SUCCESS) {
        throw WindowsException(HRESULT_FROM_WIN32(getProxyResultStatus));
      }
      arena.onReleaseAll(() => winHttpLib.WinHttpFreeProxyResult(proxyResult));

      final output = <Proxy>[];
      for (var entryIndex = 0; entryIndex < proxyResult.ref.cEntries; entryIndex++) {
        final entry = proxyResult.ref.pEntries[entryIndex];

        if (entry.fProxy == FALSE) {
          output.add(Proxy.direct());
          continue;
        }

        final ProxyType proxyType;
        switch (entry.ProxyScheme) {
          case INTERNET_SCHEME_HTTP:
            proxyType = ProxyType.http;
            break;
          case INTERNET_SCHEME_HTTPS:
            proxyType = ProxyType.https;
            break;
          case INTERNET_SCHEME_FTP:
            proxyType = ProxyType.ftp;
            break;
          case INTERNET_SCHEME_SOCKS:
            proxyType = ProxyType.socks;
            break;
          default:
            continue;
        }

        final proxy = Proxy(type: proxyType, host: entry.pwszProxy.toDartString(), port: entry.ProxyPort);
        output.add(proxy);
      }
      return output.isEmpty ? [Proxy.direct()] : UnmodifiableListView(output);
    } else {
      return null;
    }
  }
}
