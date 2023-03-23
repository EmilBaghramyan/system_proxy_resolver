// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'system_proxy_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SystemProxySettings {
  bool get autoDiscoveryEnabled => throw _privateConstructorUsedError;
  String? get autoConfigUrl => throw _privateConstructorUsedError;
  Proxy get httpProxy => throw _privateConstructorUsedError;
  Proxy get httpsProxy => throw _privateConstructorUsedError;
  Proxy get ftpProxy => throw _privateConstructorUsedError;
  Proxy get socksProxy => throw _privateConstructorUsedError;
  List<String> get bypassHostnames => throw _privateConstructorUsedError;
  bool get bypassSimpleHostnames => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SystemProxySettingsCopyWith<SystemProxySettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemProxySettingsCopyWith<$Res> {
  factory $SystemProxySettingsCopyWith(
          SystemProxySettings value, $Res Function(SystemProxySettings) then) =
      _$SystemProxySettingsCopyWithImpl<$Res, SystemProxySettings>;
  @useResult
  $Res call(
      {bool autoDiscoveryEnabled,
      String? autoConfigUrl,
      Proxy httpProxy,
      Proxy httpsProxy,
      Proxy ftpProxy,
      Proxy socksProxy,
      List<String> bypassHostnames,
      bool bypassSimpleHostnames});

  $ProxyCopyWith<$Res> get httpProxy;
  $ProxyCopyWith<$Res> get httpsProxy;
  $ProxyCopyWith<$Res> get ftpProxy;
  $ProxyCopyWith<$Res> get socksProxy;
}

/// @nodoc
class _$SystemProxySettingsCopyWithImpl<$Res, $Val extends SystemProxySettings>
    implements $SystemProxySettingsCopyWith<$Res> {
  _$SystemProxySettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoDiscoveryEnabled = null,
    Object? autoConfigUrl = freezed,
    Object? httpProxy = null,
    Object? httpsProxy = null,
    Object? ftpProxy = null,
    Object? socksProxy = null,
    Object? bypassHostnames = null,
    Object? bypassSimpleHostnames = null,
  }) {
    return _then(_value.copyWith(
      autoDiscoveryEnabled: null == autoDiscoveryEnabled
          ? _value.autoDiscoveryEnabled
          : autoDiscoveryEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoConfigUrl: freezed == autoConfigUrl
          ? _value.autoConfigUrl
          : autoConfigUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      httpProxy: null == httpProxy
          ? _value.httpProxy
          : httpProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      httpsProxy: null == httpsProxy
          ? _value.httpsProxy
          : httpsProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      ftpProxy: null == ftpProxy
          ? _value.ftpProxy
          : ftpProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      socksProxy: null == socksProxy
          ? _value.socksProxy
          : socksProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      bypassHostnames: null == bypassHostnames
          ? _value.bypassHostnames
          : bypassHostnames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bypassSimpleHostnames: null == bypassSimpleHostnames
          ? _value.bypassSimpleHostnames
          : bypassSimpleHostnames // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProxyCopyWith<$Res> get httpProxy {
    return $ProxyCopyWith<$Res>(_value.httpProxy, (value) {
      return _then(_value.copyWith(httpProxy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProxyCopyWith<$Res> get httpsProxy {
    return $ProxyCopyWith<$Res>(_value.httpsProxy, (value) {
      return _then(_value.copyWith(httpsProxy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProxyCopyWith<$Res> get ftpProxy {
    return $ProxyCopyWith<$Res>(_value.ftpProxy, (value) {
      return _then(_value.copyWith(ftpProxy: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProxyCopyWith<$Res> get socksProxy {
    return $ProxyCopyWith<$Res>(_value.socksProxy, (value) {
      return _then(_value.copyWith(socksProxy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_SystemProxySettingsCopyWith<$Res>
    implements $SystemProxySettingsCopyWith<$Res> {
  factory _$$_SystemProxySettingsCopyWith(_$_SystemProxySettings value,
          $Res Function(_$_SystemProxySettings) then) =
      __$$_SystemProxySettingsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool autoDiscoveryEnabled,
      String? autoConfigUrl,
      Proxy httpProxy,
      Proxy httpsProxy,
      Proxy ftpProxy,
      Proxy socksProxy,
      List<String> bypassHostnames,
      bool bypassSimpleHostnames});

  @override
  $ProxyCopyWith<$Res> get httpProxy;
  @override
  $ProxyCopyWith<$Res> get httpsProxy;
  @override
  $ProxyCopyWith<$Res> get ftpProxy;
  @override
  $ProxyCopyWith<$Res> get socksProxy;
}

/// @nodoc
class __$$_SystemProxySettingsCopyWithImpl<$Res>
    extends _$SystemProxySettingsCopyWithImpl<$Res, _$_SystemProxySettings>
    implements _$$_SystemProxySettingsCopyWith<$Res> {
  __$$_SystemProxySettingsCopyWithImpl(_$_SystemProxySettings _value,
      $Res Function(_$_SystemProxySettings) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoDiscoveryEnabled = null,
    Object? autoConfigUrl = freezed,
    Object? httpProxy = null,
    Object? httpsProxy = null,
    Object? ftpProxy = null,
    Object? socksProxy = null,
    Object? bypassHostnames = null,
    Object? bypassSimpleHostnames = null,
  }) {
    return _then(_$_SystemProxySettings(
      autoDiscoveryEnabled: null == autoDiscoveryEnabled
          ? _value.autoDiscoveryEnabled
          : autoDiscoveryEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      autoConfigUrl: freezed == autoConfigUrl
          ? _value.autoConfigUrl
          : autoConfigUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      httpProxy: null == httpProxy
          ? _value.httpProxy
          : httpProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      httpsProxy: null == httpsProxy
          ? _value.httpsProxy
          : httpsProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      ftpProxy: null == ftpProxy
          ? _value.ftpProxy
          : ftpProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      socksProxy: null == socksProxy
          ? _value.socksProxy
          : socksProxy // ignore: cast_nullable_to_non_nullable
              as Proxy,
      bypassHostnames: null == bypassHostnames
          ? _value._bypassHostnames
          : bypassHostnames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bypassSimpleHostnames: null == bypassSimpleHostnames
          ? _value.bypassSimpleHostnames
          : bypassSimpleHostnames // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_SystemProxySettings extends _SystemProxySettings {
  const _$_SystemProxySettings(
      {required this.autoDiscoveryEnabled,
      this.autoConfigUrl,
      required this.httpProxy,
      required this.httpsProxy,
      required this.ftpProxy,
      required this.socksProxy,
      required final List<String> bypassHostnames,
      required this.bypassSimpleHostnames})
      : _bypassHostnames = bypassHostnames,
        super._();

  @override
  final bool autoDiscoveryEnabled;
  @override
  final String? autoConfigUrl;
  @override
  final Proxy httpProxy;
  @override
  final Proxy httpsProxy;
  @override
  final Proxy ftpProxy;
  @override
  final Proxy socksProxy;
  final List<String> _bypassHostnames;
  @override
  List<String> get bypassHostnames {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bypassHostnames);
  }

  @override
  final bool bypassSimpleHostnames;

  @override
  String toString() {
    return 'SystemProxySettings(autoDiscoveryEnabled: $autoDiscoveryEnabled, autoConfigUrl: $autoConfigUrl, httpProxy: $httpProxy, httpsProxy: $httpsProxy, ftpProxy: $ftpProxy, socksProxy: $socksProxy, bypassHostnames: $bypassHostnames, bypassSimpleHostnames: $bypassSimpleHostnames)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SystemProxySettings &&
            (identical(other.autoDiscoveryEnabled, autoDiscoveryEnabled) ||
                other.autoDiscoveryEnabled == autoDiscoveryEnabled) &&
            (identical(other.autoConfigUrl, autoConfigUrl) ||
                other.autoConfigUrl == autoConfigUrl) &&
            (identical(other.httpProxy, httpProxy) ||
                other.httpProxy == httpProxy) &&
            (identical(other.httpsProxy, httpsProxy) ||
                other.httpsProxy == httpsProxy) &&
            (identical(other.ftpProxy, ftpProxy) ||
                other.ftpProxy == ftpProxy) &&
            (identical(other.socksProxy, socksProxy) ||
                other.socksProxy == socksProxy) &&
            const DeepCollectionEquality()
                .equals(other._bypassHostnames, _bypassHostnames) &&
            (identical(other.bypassSimpleHostnames, bypassSimpleHostnames) ||
                other.bypassSimpleHostnames == bypassSimpleHostnames));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      autoDiscoveryEnabled,
      autoConfigUrl,
      httpProxy,
      httpsProxy,
      ftpProxy,
      socksProxy,
      const DeepCollectionEquality().hash(_bypassHostnames),
      bypassSimpleHostnames);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SystemProxySettingsCopyWith<_$_SystemProxySettings> get copyWith =>
      __$$_SystemProxySettingsCopyWithImpl<_$_SystemProxySettings>(
          this, _$identity);
}

abstract class _SystemProxySettings extends SystemProxySettings {
  const factory _SystemProxySettings(
      {required final bool autoDiscoveryEnabled,
      final String? autoConfigUrl,
      required final Proxy httpProxy,
      required final Proxy httpsProxy,
      required final Proxy ftpProxy,
      required final Proxy socksProxy,
      required final List<String> bypassHostnames,
      required final bool bypassSimpleHostnames}) = _$_SystemProxySettings;
  const _SystemProxySettings._() : super._();

  @override
  bool get autoDiscoveryEnabled;
  @override
  String? get autoConfigUrl;
  @override
  Proxy get httpProxy;
  @override
  Proxy get httpsProxy;
  @override
  Proxy get ftpProxy;
  @override
  Proxy get socksProxy;
  @override
  List<String> get bypassHostnames;
  @override
  bool get bypassSimpleHostnames;
  @override
  @JsonKey(ignore: true)
  _$$_SystemProxySettingsCopyWith<_$_SystemProxySettings> get copyWith =>
      throw _privateConstructorUsedError;
}
