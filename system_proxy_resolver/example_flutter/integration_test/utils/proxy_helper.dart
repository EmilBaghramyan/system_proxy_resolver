import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:system_proxy_resolver/system_proxy_resolver.dart';

import 'proxy_helper_darwin.dart';
import 'proxy_helper_windows.dart';

abstract class ProxyHelper {
  const ProxyHelper();

  factory ProxyHelper.platform() {
    if (Platform.isWindows) {
      return WindowsProxyHelper();
    } else if (Platform.isIOS || Platform.isMacOS) {
      return DarwinProxyHelper();
    } else {
      throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
    }
  }

  void setSystemProxySettings(SystemProxySettings settings);

  void resetSystemProxySettings() {
    final settings = SystemProxySettings(
      autoDiscoveryEnabled: false,
      httpProxy: Proxy.direct(),
      httpsProxy: Proxy.direct(),
      ftpProxy: Proxy.direct(),
      socksProxy: Proxy.direct(),
      bypassHostnames: [],
      bypassSimpleHostnames: false,
    );
    setSystemProxySettings(settings);
  }

  void setProxyForAllProtocols(String host, int port);

  Matcher match(SystemProxySettings settings) => equals(settings);
}
