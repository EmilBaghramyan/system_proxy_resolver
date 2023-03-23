import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';
import 'package:system_proxy_resolver_foundation/src/libs.dart';

Pointer<CFRunLoop> get proxyAutoConfigurationRunLoop => cfLib.CFRunLoopGetCurrent();

final CFProxyAutoConfigurationResultCallback proxyAutoConfigurationResultCallback =
    Pointer.fromFunction(_proxyAutoConfigurationResultCallback);

void freeCFProxyAutoConfigurationResult(Pointer<CFProxyAutoConfigurationResult> result) {
  malloc.free(result);
}

Future<Pointer<CFProxyAutoConfigurationResult>> waitResult(ReceivePort receivePort) async {
  dynamic result;
  receivePort.take(1).listen((message) => result = message);
  do {
    cfLib.CFRunLoopRunInMode(cfLib.kCFRunLoopDefaultMode, 0.01, true);
    await Future.delayed(const Duration(milliseconds: 1));
  } while (result == null);
  return Pointer.fromAddress(result as int);
}

void _proxyAutoConfigurationResultCallback(Pointer<Void> client, Pointer<CFArray> proxyList, Pointer<CFError> error) {
  final result = malloc<CFProxyAutoConfigurationResult>()
    ..ref.proxyList = proxyList
    ..ref.error = error;
  final cObject = malloc<Dart_CObject>()
    ..ref.type = Dart_CObject_Type.Dart_CObject_kInt64
    ..ref.value.as_int64 = result.address;
  final sendPort = client.address;
  if (_postCObject(sendPort, cObject) > 0) {
    cfLib.CFSafeRetain(proxyList.cast());
    cfLib.CFSafeRetain(error.cast());
  }
}

final _postCObject = NativeApi.postCObject
    .cast<NativeFunction<Int8 Function(Int64, Pointer<Dart_CObject>)>>()
    .asFunction<int Function(int, Pointer<Dart_CObject>)>();
