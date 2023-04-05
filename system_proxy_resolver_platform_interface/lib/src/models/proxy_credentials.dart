import 'package:freezed_annotation/freezed_annotation.dart';

part 'proxy_credentials.freezed.dart';

@freezed
class ProxyCredentials with _$ProxyCredentials {
  const factory ProxyCredentials({
    required String username,
    required String password,
  }) = _ProxyCredentials;
}
