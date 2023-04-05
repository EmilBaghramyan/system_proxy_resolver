import 'dart:ffi';
import 'dart:isolate';

import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';
import 'package:system_proxy_resolver_foundation/src/libs.dart';

final Future<Pointer<CFRunLoop>> proxyAutoConfigurationRunLoop = (() {
  final callbackPort = ReceivePort();
  helperLib.initializeProxyResolverRunLoop(NativeApi.postCObject.cast(), callbackPort.sendPort.nativePort);
  return callbackPort.first.then((value) => Pointer<CFRunLoop>.fromAddress(value as int));
})();

final CFProxyAutoConfigurationResultCallback proxyAutoConfigurationResultCallback =
    helperLib.proxyAutoConfigurationResultCallback;

void freeCFProxyAutoConfigurationResult(Pointer<CFProxyAutoConfigurationResult> result) =>
    helperLib.freeCFProxyAutoConfigurationResult(result);

Future<Pointer<CFProxyAutoConfigurationResult>> waitResult(ReceivePort receivePort) =>
    receivePort.first.then((value) => Pointer.fromAddress(value as int));
