import 'package:flutter_test/flutter_test.dart';
import 'package:system_proxy_resolver/src/system_proxy_resolver.dart';
import 'package:system_proxy_resolver/src/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver/system_proxy_resolver_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSystemProxyResolverPlatform
    with MockPlatformInterfaceMixin
    implements SystemProxyResolverPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SystemProxyResolverPlatform initialPlatform =
      SystemProxyResolverPlatform.instance;

  test('$MethodChannelSystemProxyResolver is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSystemProxyResolver>());
  });

  test('getPlatformVersion', () async {
    SystemProxyResolver systemProxyResolverPlugin = SystemProxyResolver();
    MockSystemProxyResolverPlatform fakePlatform =
        MockSystemProxyResolverPlatform();
    SystemProxyResolverPlatform.instance = fakePlatform;

    expect(await systemProxyResolverPlugin.getPlatformVersion(), '42');
  });
}
