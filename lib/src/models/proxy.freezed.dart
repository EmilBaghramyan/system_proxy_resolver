// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'proxy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Proxy {
  ProxyType get type => throw _privateConstructorUsedError;
  String get host => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  ProxyCredentials? get credentials => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProxyCopyWith<Proxy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyCopyWith<$Res> {
  factory $ProxyCopyWith(Proxy value, $Res Function(Proxy) then) =
      _$ProxyCopyWithImpl<$Res, Proxy>;
  @useResult
  $Res call(
      {ProxyType type, String host, int port, ProxyCredentials? credentials});

  $ProxyCredentialsCopyWith<$Res>? get credentials;
}

/// @nodoc
class _$ProxyCopyWithImpl<$Res, $Val extends Proxy>
    implements $ProxyCopyWith<$Res> {
  _$ProxyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? host = null,
    Object? port = null,
    Object? credentials = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxyType,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      credentials: freezed == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as ProxyCredentials?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProxyCredentialsCopyWith<$Res>? get credentials {
    if (_value.credentials == null) {
      return null;
    }

    return $ProxyCredentialsCopyWith<$Res>(_value.credentials!, (value) {
      return _then(_value.copyWith(credentials: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_ProxyCopyWith<$Res> implements $ProxyCopyWith<$Res> {
  factory _$$_ProxyCopyWith(_$_Proxy value, $Res Function(_$_Proxy) then) =
      __$$_ProxyCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ProxyType type, String host, int port, ProxyCredentials? credentials});

  @override
  $ProxyCredentialsCopyWith<$Res>? get credentials;
}

/// @nodoc
class __$$_ProxyCopyWithImpl<$Res> extends _$ProxyCopyWithImpl<$Res, _$_Proxy>
    implements _$$_ProxyCopyWith<$Res> {
  __$$_ProxyCopyWithImpl(_$_Proxy _value, $Res Function(_$_Proxy) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? host = null,
    Object? port = null,
    Object? credentials = freezed,
  }) {
    return _then(_$_Proxy(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxyType,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      credentials: freezed == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as ProxyCredentials?,
    ));
  }
}

/// @nodoc

class _$_Proxy extends _Proxy {
  const _$_Proxy(
      {required this.type,
      required this.host,
      required this.port,
      this.credentials})
      : super._();

  @override
  final ProxyType type;
  @override
  final String host;
  @override
  final int port;
  @override
  final ProxyCredentials? credentials;

  @override
  String toString() {
    return 'Proxy(type: $type, host: $host, port: $port, credentials: $credentials)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Proxy &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.credentials, credentials) ||
                other.credentials == credentials));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type, host, port, credentials);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ProxyCopyWith<_$_Proxy> get copyWith =>
      __$$_ProxyCopyWithImpl<_$_Proxy>(this, _$identity);
}

abstract class _Proxy extends Proxy {
  const factory _Proxy(
      {required final ProxyType type,
      required final String host,
      required final int port,
      final ProxyCredentials? credentials}) = _$_Proxy;
  const _Proxy._() : super._();

  @override
  ProxyType get type;
  @override
  String get host;
  @override
  int get port;
  @override
  ProxyCredentials? get credentials;
  @override
  @JsonKey(ignore: true)
  _$$_ProxyCopyWith<_$_Proxy> get copyWith =>
      throw _privateConstructorUsedError;
}
