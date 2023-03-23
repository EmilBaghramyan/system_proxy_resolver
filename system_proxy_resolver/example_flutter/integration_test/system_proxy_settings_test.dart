import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:system_proxy_resolver/system_proxy_resolver.dart';

import 'utils/proxy_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final helper = ProxyHelper.platform();
  final plugin = SystemProxyResolver();

  testWidgets("can read arbitrary proxy settings", (_) async {
    final settings = SystemProxySettings(
      autoDiscoveryEnabled: true,
      httpProxy: Proxy.direct(),
      httpsProxy: const Proxy(type: ProxyType.https, host: "github.com", port: 8080),
      ftpProxy: Proxy.direct(),
      socksProxy: Proxy.direct(),
      bypassHostnames: ["google.com"],
      bypassSimpleHostnames: true,
    );
    helper.setSystemProxySettings(settings);

    expect(plugin.getSystemProxySettings(), helper.match(settings));
  });

  testWidgets("can read `one proxy for all protocols` correctly", (_) async {
    const host = "yahoo.com";
    const port = 22;
    helper.setProxyForAllProtocols(host, port);

    final result = plugin.getSystemProxySettings();

    expect([result.httpProxy.host, result.httpsProxy.host, result.ftpProxy.host], equals([host, host, host]));
    expect([result.httpProxy.port, result.httpsProxy.port, result.ftpProxy.port], equals([port, port, port]));
    expect(result.socksProxy.direct, true);
  });
}
