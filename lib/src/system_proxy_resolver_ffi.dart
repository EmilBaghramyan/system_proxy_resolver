import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver/src/system_proxy_resolver_bindings_generated.dart' as ffi;
import 'package:system_proxy_resolver/system_proxy_resolver.dart';
import 'package:system_proxy_resolver/system_proxy_resolver_platform_interface.dart';
import 'package:win32/win32.dart';

class FfiSystemProxyResolver extends SystemProxyResolverPlatform {
  static const String _libName = 'system_proxy_resolver';

  /// The dynamic library in which the symbols for [SystemProxyResolverBindings] can be found.
  static final DynamicLibrary _dylib = () {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('$_libName.framework/$_libName');
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$_libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$_libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }();

  /// The bindings to the native functions in [_dylib].
  static final ffi.SystemProxyResolverBindings _bindings = () {
    final bindings = ffi.SystemProxyResolverBindings(_dylib);
    bindings.initializeSystemProxyResolver(NativeApi.initializeApiDLData);
    return bindings;
  }();

  @override
  SystemProxySettings getSystemProxySettings() {
    final ffiResultPtr = _bindings.getSystemProxySettings();
    try {
      if (!ffiResultPtr.ref.success) {
        throw _failureToException(ffiResultPtr.ref.value.failure);
      }

      final ffiResult = ffiResultPtr.ref.value.success;
      return SystemProxySettings(
        autoDiscoveryEnabled: ffiResult.autoDiscoveryEnabled,
        autoConfigUrl: ffiResult.autoConfigUrl == nullptr ? null : ffiResult.autoConfigUrl.cast<Utf8>().toDartString(),
        httpProxy: _ffiProxyToProxy(ffiResult.httpProxy),
        httpsProxy: _ffiProxyToProxy(ffiResult.httpsProxy),
        ftpProxy: _ffiProxyToProxy(ffiResult.ftpProxy),
        socksProxy: _ffiProxyToProxy(ffiResult.socksProxy),
        bypassHostnames: List.generate(ffiResult.bypassHostnamesLength, (index) {
          final cStr = ffiResult.bypassHostnames[index].cast<Utf8>();
          return cStr.toDartString();
        }),
        bypassSimpleHostnames: ffiResult.bypassSimpleHostnames,
      );
    } finally {
      _bindings.freeGetSystemProxySettingsResult(ffiResultPtr);
    }
  }

  @override
  Future<List<Proxy>> getProxyForUrl(String url) async {
    final port = ReceivePort();
    final urlPtr = url.toNativeUtf8();
    Pointer<ffi.GetProxyForUrlResult>? outerFfiResultPtr;
    try {
      _bindings.getProxyForUrl(urlPtr.cast(), port.sendPort.nativePort);
      final ffiResultPtrAsInt = await port.first as int;
      final ffiResultPtr = Pointer<ffi.GetProxyForUrlResult>.fromAddress(ffiResultPtrAsInt);
      outerFfiResultPtr = ffiResultPtr;

      if (!ffiResultPtr.ref.success) {
        throw _failureToException(ffiResultPtr.ref.value.failure);
      }

      final ffiResult = ffiResultPtr.ref.value.success;
      final result = List<Proxy>.generate(ffiResult.chainLength, (index) {
        return _ffiProxyToProxy(ffiResult.chain[index]);
      });

      if (result.isEmpty) {
        return const [Proxy(type: ProxyType.direct, host: "", port: 0)];
      } else {
        return result;
      }
    } finally {
      malloc.free(urlPtr);
      if (outerFfiResultPtr != null) {
        _bindings.freeGetProxyForUrlResult(outerFfiResultPtr);
      }
    }
  }

  Exception _failureToException(ffi.Failure failure) {
    switch (failure.type) {
      case ffi.FailureType.FailureType_WindowsErrorCode:
        return WindowsException(failure.value.windowsErrorCode);
      case ffi.FailureType.FailureType_Message:
        return Exception(failure.value.message.cast<Utf8>().toDartString());
      default:
        throw UnimplementedError("Unknown failure type");
    }
  }

  Proxy _ffiProxyToProxy(ffi.Proxy proxy) {
    ProxyCredentials? credentials;
    if (proxy.credentials.username != nullptr && proxy.credentials.password != nullptr) {
      credentials = ProxyCredentials(
        username: proxy.credentials.username.cast<Utf8>().toDartString(),
        password: proxy.credentials.password.cast<Utf8>().toDartString(),
      );
    }
    return Proxy(
      type: _ffiProxyTypeMap[proxy.type]!,
      host: proxy.host == nullptr ? "" : proxy.host.cast<Utf8>().toDartString(),
      port: proxy.port,
      credentials: credentials,
    );
  }

  static const _ffiProxyTypeMap = {
    ffi.ProxyType.ProxyType_Direct: ProxyType.direct,
    ffi.ProxyType.ProxyType_Http: ProxyType.http,
    ffi.ProxyType.ProxyType_Https: ProxyType.https,
    ffi.ProxyType.ProxyType_Ftp: ProxyType.ftp,
    ffi.ProxyType.ProxyType_Socks: ProxyType.socks,
  };
}
