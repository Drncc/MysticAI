// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppProfile _$AppProfileFromJson(Map<String, dynamic> json) => AppProfile(
      id: json['id'] as String,
      username: json['username'] as String?,
      digitalConsent: json['digital_consent'] as bool,
      bioMetrics:
          BioMetrics.fromJson(json['bio_metrics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppProfileToJson(AppProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'digital_consent': instance.digitalConsent,
      'bio_metrics': instance.bioMetrics,
    };

BioMetrics _$BioMetricsFromJson(Map<String, dynamic> json) => BioMetrics(
      age: (json['age'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
    );

Map<String, dynamic> _$BioMetricsToJson(BioMetrics instance) =>
    <String, dynamic>{
      'age': instance.age,
      'height': instance.height,
      'weight': instance.weight,
    };
