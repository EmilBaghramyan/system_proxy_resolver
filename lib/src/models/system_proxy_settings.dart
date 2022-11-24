import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_proxy_resolver/src/models/proxy.dart';

part 'system_proxy_settings.freezed.dart';

@freezed
class SystemProxySettings with _$SystemProxySettings {
  const factory SystemProxySettings({
    required bool autoDiscoveryEnabled,
    String? autoConfigUrl,
    Proxy? httpProxy,
    Proxy? httpsProxy,
    required List<String> bypassHostnames,
    required bool bypassSimpleHostnames,
  }) = _SystemProxySettings;
}
