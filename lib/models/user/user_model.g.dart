// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      subscriptionProductId: json['subscriptionProductId'] as String?,
      subscriptionExpirationDate: json['subscriptionExpirationDate'] as String?,
      canvasScale: (json['canvasScale'] as num?)?.toDouble() ?? 1.0,
      canvasOffsetX: (json['canvasOffsetX'] as num?)?.toDouble() ?? 0.0,
      canvasOffsetY: (json['canvasOffsetY'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isEmailVerified': instance.isEmailVerified,
      'isSubscribed': instance.isSubscribed,
      'subscriptionProductId': instance.subscriptionProductId,
      'subscriptionExpirationDate': instance.subscriptionExpirationDate,
      'canvasScale': instance.canvasScale,
      'canvasOffsetX': instance.canvasOffsetX,
      'canvasOffsetY': instance.canvasOffsetY,
    };
