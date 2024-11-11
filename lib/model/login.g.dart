// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      success: json['success'] as bool,
      message: json['message'] as String,
      token: json['token'] as String?,
      storeId: json['storeId'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'token': instance.token,
      'storeId': instance.storeId,
    };
