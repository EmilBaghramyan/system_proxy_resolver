// ignore_for_file: avoid_print

import 'package:system_proxy_resolver/system_proxy_resolver.dart';

void main() async {
  final resolver = SystemProxyResolver();
  print(resolver.getSystemProxySettings());
  print(await resolver.getProxyForUrl(Uri.parse("https://pub.dev")));
}
