import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:system_proxy_resolver/system_proxy_resolver.dart';

import 'proxy_helper.dart';

class DarwinProxyHelper extends ProxyHelper {
  static const _wpadUrl = "http://wpad/wpad.dat";

  static const _onValue = "on";
  static const _offValue = "off";

  static const _setProxyAutoDiscoveryCmd = "setproxyautodiscovery";

  static const _setAutoProxyStateCmd = "setautoproxystate";
  static const _setAutoProxyUrlCmd = "setautoproxyurl";

  static const _setHttpProxyStateCmd = "setwebproxystate";
  static const _setHttpProxyCmd = "setwebproxy";

  static const _setHttpsProxyStateCmd = "setsecurewebproxystate";
  static const _setHttpsProxyCmd = "setsecurewebproxy";

  static const _setFtpProxyStateCmd = "setftpproxystate";
  static const _setFtpProxyCmd = "setftpproxy";

  static const _setSocksProxyStateCmd = "setsocksfirewallproxystate";
  static const _setSocksProxyCmd = "setsocksfirewallproxy";

  static const _getProxyBypassDomainsCmd = "getproxybypassdomains";
  static const _setProxyBypassDomainsCmd = "setproxybypassdomains";

  @override
  void setSystemProxySettings(SystemProxySettings settings) {
    _networkSetup(_setProxyAutoDiscoveryCmd, [if (settings.autoDiscoveryEnabled) _onValue else _offValue]);
    if (settings.autoConfigUrl == null) {
      _networkSetup(_setAutoProxyStateCmd, [_offValue]);
    } else {
      _networkSetup(_setAutoProxyStateCmd, [_onValue]);
      _networkSetup(_setAutoProxyUrlCmd, [settings.autoConfigUrl!]);
    }

    _networkSetup(_setHttpProxyCmd, [settings.httpProxy.host, settings.httpProxy.port.toString()]);
    _networkSetup(_setHttpProxyStateCmd, [if (settings.httpProxy.direct) _offValue else _onValue]);

    _networkSetup(_setHttpsProxyCmd, [settings.httpsProxy.host, settings.httpsProxy.port.toString()]);
    _networkSetup(_setHttpsProxyStateCmd, [if (settings.httpsProxy.direct) _offValue else _onValue]);

    _networkSetup(_setFtpProxyCmd, [settings.ftpProxy.host, settings.ftpProxy.port.toString()]);
    _networkSetup(_setFtpProxyStateCmd, [if (settings.ftpProxy.direct) _offValue else _onValue]);

    _networkSetup(_setSocksProxyCmd, [settings.socksProxy.host, settings.socksProxy.port.toString()]);
    _networkSetup(_setSocksProxyStateCmd, [if (settings.socksProxy.direct) _offValue else _onValue]);

    _networkSetup(_setProxyBypassDomainsCmd, settings.bypassHostnames);
    _networkSetup(_getProxyBypassDomainsCmd, []);
  }

  @override
  void setProxyForAllProtocols(String host, int port) {
    _networkSetup(_setHttpProxyStateCmd, [_onValue]);
    _networkSetup(_setHttpProxyCmd, [host, port.toString()]);

    _networkSetup(_setHttpsProxyStateCmd, [_onValue]);
    _networkSetup(_setHttpsProxyCmd, [host, port.toString()]);

    _networkSetup(_setFtpProxyStateCmd, [_onValue]);
    _networkSetup(_setFtpProxyCmd, [host, port.toString()]);

    _networkSetup(_setSocksProxyStateCmd, [_offValue]);
  }

  @override
  Matcher match(SystemProxySettings settings) {
    if (settings.autoDiscoveryEnabled && settings.autoConfigUrl == null) {
      return anyOf(settings, settings.copyWith(autoConfigUrl: _wpadUrl));
    } else if (settings.autoDiscoveryEnabled && settings.autoConfigUrl != null) {
      return anyOf(settings, settings.copyWith(autoDiscoveryEnabled: false));
    } else {
      return equals(settings);
    }
  }

  void _networkSetup(String command, List<String> value) {
    final result = Process.runSync("networksetup", ["-$command", "wi-fi", ...value]);
    if (result.exitCode != 0) {
      throw AssertionError(result.stdout);
    }
  }
}
