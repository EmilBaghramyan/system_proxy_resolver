# system\_proxy\_resolver

[![pub package](https://img.shields.io/pub/v/system_proxy_resolver.svg)](https://pub.dev/packages/system_proxy_resolver)

A Dart Package to read proxy settings from the OS. With this plugin you can resolve proxy 
setting for specific URL via [PAC](https://en.wikipedia.org/wiki/Proxy_auto-config) scripts.
`system_proxy_resolver` can be used in pure Dart as well!

## Features

- [x] FFI implementation so that package can be used from any isolate without additional configuration
- [x] Support for both pure Dart and Flutter projects
- [x] iOS&macOS support via [CFNetwork](https://developer.apple.com/documentation/cfnetwork)
- [x] Windows support via [WinHTTP](https://learn.microsoft.com/en-us/windows/win32/winhttp/about-winhttp)
- [ ] Android support via [IProxyService](https://android.googlesource.com/platform/frameworks/base/+/android-6.0.1_r16/core/java/android/net/PacProxySelector.java)
- [ ] Linux support via [libproxy](https://github.com/libproxy/libproxy)

## Usage

```dart
final resolver = SystemProxyResolver();
print(resolver.getSystemProxySettings());
print(await resolver.getProxyForUrl(Uri.parse("https://pub.dev")));
```

Usage with [delayed_proxy_http_client](https://github.com/ky1vstar/delayed_proxy_http_client)

```dart
final client = DelayedProxyHttpClient();
client.findProxyAsync = (url) async {
  try {
    final proxies = await proxyResolver.getProxyForUrl(url);
    return proxies.map((e) => e.direct ? "DIRECT" : "PROXY ${e.host}:${e.port}").join("; ");
  } on Object catch (e) {
    return "DIRECT";
  }
};

...
```
