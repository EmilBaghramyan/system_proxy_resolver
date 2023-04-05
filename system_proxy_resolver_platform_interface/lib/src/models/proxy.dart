import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';

part 'proxy.freezed.dart';

@freezed
class Proxy with _$Proxy {
  const factory Proxy({
    required ProxyType type,
    required String host,
    required int port,
    ProxyCredentials? credentials,
  }) = _Proxy;

  const Proxy._();

  factory Proxy.direct() => const Proxy(type: ProxyType.direct, host: "", port: 0);

  bool get direct => type == ProxyType.direct;
}
