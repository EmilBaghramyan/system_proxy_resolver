import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';
import 'package:system_proxy_resolver_foundation/src/libs.dart';
import 'package:system_proxy_resolver_foundation/src/proxy_auto_configuration_stub.dart'
    // if (dart.library.ui) 'package:system_proxy_resolver_foundation/src/proxy_auto_configuration_ui.dart'
    if (dart.library.ffi) 'package:system_proxy_resolver_foundation/src/proxy_auto_configuration_ffi.dart';
import 'package:system_proxy_resolver_foundation/src/utils.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';

class SystemProxyResolverFoundation extends SystemProxyResolverPlatform {
  /// Registers this class as the default instance of
  /// [SystemProxyResolverPlatform].
  static void registerWith() {
    SystemProxyResolverPlatform.instance = SystemProxyResolverFoundation();
  }

  @override
  SystemProxySettings getSystemProxySettings() {
    final releaseList = <CFTypeRef>[];
    try {
      final proxySettings = cfLib.CFNetworkCopySystemProxySettings();
      releaseList.add(proxySettings.cast());
      // print(proxySettings.cast<CFType>().description);

      final autoDiscoveryEnable =
          proxySettings.getValue(cfLib.kCFNetworkProxiesProxyAutoDiscoveryEnable.cast()).asCFNumber()?.boolValue ??
              false;

      final autoConfigEnable =
          proxySettings.getValue(cfLib.kCFNetworkProxiesProxyAutoConfigEnable.cast()).asCFNumber()?.boolValue ?? false;
      final autoConfigURLString =
          proxySettings.getValue(cfLib.kCFNetworkProxiesProxyAutoConfigURLString.cast()).asCFString();

      Proxy getProxy(
        ProxyType type,
        Pointer<CFString> enableKey,
        Pointer<CFString> hostKey,
        Pointer<CFString> portKey,
      ) {
        return _getProxy(
          type: type,
          proxyDict: proxySettings,
          enableKey: enableKey,
          hostKey: hostKey,
          portKey: portKey,
          usernameKey: null,
          passwordKey: null,
        );
      }

      final httpProxy = getProxy(
        ProxyType.http,
        cfLib.kCFNetworkProxiesHTTPEnable,
        cfLib.kCFNetworkProxiesHTTPProxy,
        cfLib.kCFNetworkProxiesHTTPPort,
      );

      final httpsProxy = getProxy(
        ProxyType.https,
        cfLib.kCFNetworkProxiesHTTPSProxy,
        cfLib.kCFNetworkProxiesHTTPSProxy,
        cfLib.kCFNetworkProxiesHTTPSPort,
      );

      final ftpProxy = getProxy(
        ProxyType.ftp,
        cfLib.kCFNetworkProxiesFTPEnable,
        cfLib.kCFNetworkProxiesFTPProxy,
        cfLib.kCFNetworkProxiesFTPPort,
      );

      final socksProxy = getProxy(
        ProxyType.socks,
        cfLib.kCFNetworkProxiesSOCKSEnable,
        cfLib.kCFNetworkProxiesSOCKSProxy,
        cfLib.kCFNetworkProxiesSOCKSPort,
      );

      final exceptionsListRef = proxySettings.getValue(cfLib.kCFNetworkProxiesExceptionsList.cast()).asCFArray();
      final exceptionsList = Iterable.generate(exceptionsListRef?.count ?? 0, (index) {
        return exceptionsListRef!.getValue(index).asCFString()?.toDartString();
      }).whereType<String>().toList(growable: false);

      final excludeSimpleHostnames =
          proxySettings.getValue(cfLib.kCFNetworkProxiesExcludeSimpleHostnames.cast()).asCFNumber()?.boolValue ?? false;

      return SystemProxySettings(
        autoDiscoveryEnabled: autoDiscoveryEnable,
        autoConfigUrl: autoConfigEnable ? autoConfigURLString?.toDartString() : null,
        httpProxy: httpProxy,
        httpsProxy: httpsProxy,
        ftpProxy: ftpProxy,
        socksProxy: socksProxy,
        bypassHostnames: exceptionsList,
        bypassSimpleHostnames: excludeSimpleHostnames,
      );
    } finally {
      for (final cf in releaseList) {
        cfLib.CFSafeRelease(cf);
      }
    }
  }

  @override
  Future<List<Proxy>> getProxyForUrl(String url) async {
    final releaseList = <CFTypeRef>[];
    try {
      final cfUrlString = url.toCFString();
      releaseList.add(cfUrlString.cast());

      final cfUrl = cfLib.CFURLCreateWithString(cfLib.kCFAllocatorDefault, cfUrlString, nullptr);
      releaseList.add(cfUrl.cast());

      final proxySettings = cfLib.CFNetworkCopySystemProxySettings();
      releaseList.add(proxySettings.cast());

      final proxies = cfLib.CFNetworkCopyProxiesForURL(cfUrl, proxySettings);
      releaseList.add(proxies.cast());

      return await _processProxies(proxies, cfUrl);
    } finally {
      for (final cf in releaseList) {
        cfLib.CFSafeRelease(cf);
      }
    }
  }

  static Proxy _getProxy({
    required ProxyType type,
    required Pointer<CFDictionary> proxyDict,
    required Pointer<CFString>? enableKey,
    required Pointer<CFString> hostKey,
    required Pointer<CFString> portKey,
    required Pointer<CFString>? usernameKey,
    required Pointer<CFString>? passwordKey,
  }) {
    final enable = enableKey == null || (proxyDict.getValue(enableKey.cast()).asCFNumber()?.boolValue ?? false);
    if (!enable) return Proxy.direct();
    final host = proxyDict.getValue(hostKey.cast()).asCFString();
    final port = proxyDict.getValue(portKey.cast()).asCFNumber();
    ProxyCredentials? credentials;
    if (usernameKey != null && passwordKey != null) {
      final username = proxyDict.getValue(usernameKey.cast()).asCFString();
      final password = proxyDict.getValue(passwordKey.cast()).asCFString();
      if (username != null && password != null) {
        credentials = ProxyCredentials(username: username.toDartString(), password: password.toDartString());
      }
    }
    return Proxy(
      type: type,
      host: host?.toDartString() ?? "",
      port: port?.unsignedShortValue ?? 0,
      credentials: credentials,
    );
  }

  Future<List<Proxy>> _processProxies(Pointer<CFArray> proxies, Pointer<CFURL> targetUrl) async {
    final result = <Proxy>[];

    for (var index = 0; index < proxies.count; index++) {
      final proxyDict = proxies.getValue(index).asCFDictionary();
      if (proxyDict == null) continue;

      final type = proxyDict.getValue(cfLib.kCFProxyTypeKey.cast());
      late final ProxyType proxyType;

      if (cfLib.CFEqual(type, cfLib.kCFProxyTypeAutoConfigurationURL.cast())) {
        return using((arena) async {
          final proxyAutoConfigUrl = proxyDict.getValue(cfLib.kCFProxyAutoConfigurationURLKey.cast());
          final callbackPort = ReceivePort();
          final context = arena<CFStreamClientContext>()
            ..ref.info = Pointer.fromAddress(callbackPort.sendPort.nativePort);
          final source = cfLib.CFNetworkExecuteProxyAutoConfigurationURL(
            proxyAutoConfigUrl.cast(),
            targetUrl,
            proxyAutoConfigurationResultCallback,
            context,
          );
          cfLib.CFRunLoopAddSource(proxyAutoConfigurationRunLoop, source, cfLib.kCFRunLoopDefaultMode);

          final callbackResult = await waitResult(callbackPort);
          final proxyList = callbackResult.ref.proxyList;
          final error = callbackResult.ref.error;
          freeCFProxyAutoConfigurationResult(callbackResult);
          arena.onReleaseAll(() => cfLib.CFSafeRelease(proxyList.cast()));
          arena.onReleaseAll(() => cfLib.CFSafeRelease(error.cast()));

          if (proxyList != nullptr) {
            return _processProxies(proxyList, targetUrl);
          } else {
            throw Exception(error.cast<CFType>().description);
          }
        });
      } else if (cfLib.CFEqual(type, cfLib.kCFProxyTypeNone.cast())) {
        result.add(Proxy.direct());
        continue;
      } else if (cfLib.CFEqual(type, cfLib.kCFProxyTypeHTTP.cast())) {
        proxyType = ProxyType.http;
      } else if (cfLib.CFEqual(type, cfLib.kCFProxyTypeHTTPS.cast())) {
        proxyType = ProxyType.https;
      } else if (cfLib.CFEqual(type, cfLib.kCFProxyTypeFTP.cast())) {
        proxyType = ProxyType.ftp;
      } else if (cfLib.CFEqual(type, cfLib.kCFProxyTypeSOCKS.cast())) {
        proxyType = ProxyType.socks;
      } else {
        continue;
      }

      final proxy = _getProxy(
        type: proxyType,
        proxyDict: proxyDict,
        enableKey: null,
        hostKey: cfLib.kCFProxyHostNameKey,
        portKey: cfLib.kCFProxyPortNumberKey,
        usernameKey: cfLib.kCFProxyUsernameKey,
        passwordKey: cfLib.kCFProxyPasswordKey,
      );
      result.add(proxy);
    }

    return result.isEmpty ? [Proxy.direct()] : result;
  }
}
