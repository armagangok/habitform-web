import 'package:freezed_annotation/freezed_annotation.dart';

import '/core/util/timestamp_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isSubscribed,
    String? subscriptionProductId,
    String? subscriptionExpirationDate,
    @Default(1.0) double canvasScale,
    @Default(0.0) double canvasOffsetX,
    @Default(0.0) double canvasOffsetY,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
