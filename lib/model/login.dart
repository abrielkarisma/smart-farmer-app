import 'package:freezed_annotation/freezed_annotation.dart';

part 'login.g.dart';
part 'login.freezed.dart';

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required bool success,
    required String message,
    required String? token,
    required String? role,
    String? storeId,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
