// ignore_for_file: avoid_print

import 'package:system_proxy_resolver/system_proxy_resolver.dart';

void main() async {
  final resolver = SystemProxyResolver();
  print(resolver.getSystemProxySettings());
  print(await resolver.getProxyForUrl("https://pub.dev"));
  // final proxySettings = cfNetwork.CFNetworkCopySystemProxySettings();
  // final description = cfNetwork.CFCopyDescription(proxySettings.cast());
  // print(description.toDartString());
}
