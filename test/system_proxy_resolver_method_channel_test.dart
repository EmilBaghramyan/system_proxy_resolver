import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_proxy_resolver/system_proxy_resolver_method_channel.dart';

void main() {
  MethodChannelSystemProxyResolver platform = MethodChannelSystemProxyResolver();
  const MethodChannel channel = MethodChannel('system_proxy_resolver');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
