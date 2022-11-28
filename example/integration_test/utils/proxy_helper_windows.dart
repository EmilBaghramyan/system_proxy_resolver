import 'package:system_proxy_resolver/system_proxy_resolver.dart';
import 'package:win32_registry/win32_registry.dart';

import 'proxy_helper.dart';

class WindowsProxyHelper extends ProxyHelper {
  static const _registryPath = r"Software\Microsoft\Windows\CurrentVersion\Internet Settings";
  static const _autoDetectKey = "AutoDetect";
  static const _autoConfigUrlKey = "AutoConfigURL";
  static const _proxyEnableKey = "ProxyEnable";
  static const _migrateProxyKey = "MigrateProxy";
  static const _proxyServerKey = "ProxyServer";
  static const _proxyOverrideKey = "ProxyOverride";

  @override
  void setSystemProxySettings(SystemProxySettings settings) {
    _useRegistry((registry) {
      Registry.openPath(RegistryHive.currentUser,
              path: "$_registryPath\\Connections", desiredAccessRights: AccessRights.allAccess)
          .deleteValue("DefaultConnectionSettings");
      registry
          .createValue(RegistryValue(_autoDetectKey, RegistryValueType.int32, settings.autoDiscoveryEnabled ? 1 : 0));

      if (settings.autoConfigUrl == null) {
        registry.safeDeleteValue(_autoConfigUrlKey);
      } else {
        registry.createValue(RegistryValue(_autoConfigUrlKey, RegistryValueType.string, settings.autoConfigUrl!));
      }

      registry.createValue(const RegistryValue(_migrateProxyKey, RegistryValueType.int32, 1));

      if (settings.hasAtLeastOneNonDirectProxy) {
        registry.createValue(const RegistryValue(_proxyEnableKey, RegistryValueType.int32, 0));

        final proxyString = [
          if (!settings.httpProxy.direct) "http=${settings.httpProxy.host}:${settings.httpProxy.port}",
          if (!settings.httpsProxy.direct) "https=${settings.httpsProxy.host}:${settings.httpsProxy.port}",
          if (!settings.ftpProxy.direct) "ftp=${settings.ftpProxy.host}:${settings.ftpProxy.port}",
          if (!settings.socksProxy.direct) "socks=${settings.socksProxy.host}:${settings.socksProxy.port}",
        ].join(";");
        registry.createValue(RegistryValue(_proxyServerKey, RegistryValueType.string, proxyString));

        final proxyOverride = [
          ...settings.bypassHostnames,
          if (settings.bypassSimpleHostnames) "<local>",
        ].join(";");
        if (proxyOverride.isEmpty) {
          registry.safeDeleteValue(_proxyOverrideKey);
        } else {
          registry.createValue(RegistryValue(_proxyOverrideKey, RegistryValueType.string, proxyOverride));
        }
      } else {
        registry.createValue(const RegistryValue(_proxyEnableKey, RegistryValueType.int32, 0));
        registry.safeDeleteValue(_proxyServerKey);
      }
    });
  }

  @override
  void setProxyForAllProtocols(String host, int port) {
    _useRegistry((registry) {
      registry.createValue(const RegistryValue(_migrateProxyKey, RegistryValueType.int32, 1));
      registry.createValue(const RegistryValue(_proxyEnableKey, RegistryValueType.int32, 1));
      registry.createValue(RegistryValue(_proxyServerKey, RegistryValueType.string, "$host:$port"));
    });
  }

  T _useRegistry<T>(T Function(RegistryKey registry) job) {
    final registry = Registry.openPath(
      RegistryHive.currentUser,
      path: _registryPath,
      desiredAccessRights: AccessRights.allAccess,
    );
    try {
      return job(registry);
    } finally {
      registry.close();
    }
  }
}

extension on RegistryKey {
  void safeDeleteValue(String valueName) {
    if (getValue(valueName) != null) {
      deleteValue(valueName);
    }
  }
}
