import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_proxy_resolver/src/models/proxy.dart';

part 'system_proxy_settings.freezed.dart';

@freezed
class SystemProxySettings with _$SystemProxySettings {
  const factory SystemProxySettings({
    required bool autoDiscoveryEnabled,
    String? autoConfigUrl,
    required Proxy httpProxy,
    required Proxy httpsProxy,
    required Proxy ftpProxy,
    required Proxy socksProxy,
    required List<String> bypassHostnames,
    required bool bypassSimpleHostnames,
  }) = _SystemProxySettings;
}
