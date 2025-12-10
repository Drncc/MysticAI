// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReflectionData _$ReflectionDataFromJson(Map<String, dynamic> json) =>
    ReflectionData(
      screenTimeSeconds: (json['screen_time_seconds'] as num).toInt(),
      weatherCondition: json['weather_condition'] as String,
      moodScoreRaw: (json['mood_score_raw'] as num).toDouble(),
    );

Map<String, dynamic> _$ReflectionDataToJson(ReflectionData instance) =>
    <String, dynamic>{
      'screen_time_seconds': instance.screenTimeSeconds,
      'weather_condition': instance.weatherCondition,
      'mood_score_raw': instance.moodScoreRaw,
    };

Reflection _$ReflectionFromJson(Map<String, dynamic> json) => Reflection(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      inputData:
          ReflectionData.fromJson(json['input_data'] as Map<String, dynamic>),
      narrative: json['narrative'] as String,
      moodScore: (json['mood_score'] as num).toInt(),
    );

Map<String, dynamic> _$ReflectionToJson(Reflection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'input_data': instance.inputData.toJson(),
      'narrative': instance.narrative,
      'mood_score': instance.moodScore,
    };
