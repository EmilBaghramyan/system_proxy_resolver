import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_platform_interface/unimplemented_system_proxy_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Store the initial instance before any tests change it.
  final SystemProxyResolverPlatform initialInstance = SystemProxyResolverPlatform.instance;

  group('$SystemProxyResolverPlatform', () {
    test('$UnimplementedSystemProxyResolver() is the default instance', () {
      expect(initialInstance, isInstanceOf<UnimplementedSystemProxyResolver>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(
        () {
          SystemProxyResolverPlatform.instance = ImplementsSystemProxyResolverPlatform();
        },
        throwsA(isInstanceOf<AssertionError>()),
      );
    });

    test('Can be mocked with `implements`', () {
      final SystemProxyResolverPlatformMock mock = SystemProxyResolverPlatformMock();
      SystemProxyResolverPlatform.instance = mock;
    });

    test('Can be extended', () {
      SystemProxyResolverPlatform.instance = ExtendsSystemProxyResolverPlatform();
    });
  });
}

class SystemProxyResolverPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements SystemProxyResolverPlatform {}

class ImplementsSystemProxyResolverPlatform extends Mock implements SystemProxyResolverPlatform {}

class ExtendsSystemProxyResolverPlatform extends SystemProxyResolverPlatform {}
