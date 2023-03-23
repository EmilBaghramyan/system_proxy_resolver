import 'dart:ffi';
import 'dart:isolate';

import 'package:system_proxy_resolver_foundation/src/core_foundation.g.dart';

Pointer<CFRunLoop> get proxyAutoConfigurationRunLoop => throw UnsupportedError("message");

CFProxyAutoConfigurationResultCallback get proxyAutoConfigurationResultCallback => throw UnsupportedError("message");

void freeCFProxyAutoConfigurationResult(Pointer<CFProxyAutoConfigurationResult> result) =>
    throw UnsupportedError("message");

Future<Pointer<CFProxyAutoConfigurationResult>> waitResult(ReceivePort receivePort) =>
    throw UnsupportedError("message");
