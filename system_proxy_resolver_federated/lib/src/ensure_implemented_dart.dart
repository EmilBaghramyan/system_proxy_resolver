import 'dart:io';

import 'package:system_proxy_resolver_foundation/system_proxy_resolver_foundation.dart';
import 'package:system_proxy_resolver_platform_interface/system_proxy_resolver_platform_interface.dart';
import 'package:system_proxy_resolver_platform_interface/unimplemented_system_proxy_resolver.dart';
import 'package:system_proxy_resolver_windows/system_proxy_resolver_windows.dart';

void ensureImplementedOnce() => _ensureImplementedOnce;

final void _ensureImplementedOnce = (() {
  if (SystemProxyResolverPlatform.instance is! UnimplementedSystemProxyResolver) return;

  if (Platform.isMacOS || Platform.isIOS) {
    SystemProxyResolverFoundation.registerWith();
  } else if (Platform.isWindows) {
    SystemProxyResolverWindows.registerWith();
  }
})();
