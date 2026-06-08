import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

/// Response of register / login / refresh.
@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
    required AuthUser user,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
