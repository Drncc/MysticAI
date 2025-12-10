import 'package:json_annotation/json_annotation.dart';

part 'reflection_model.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake, // Maps screenTimeSeconds -> screen_time_seconds, etc.
)
class ReflectionData {
  final int screenTimeSeconds; // In seconds, as screen time is in minutes in context, so I'll use seconds for precision if needed later, or adjust based on service output. Assuming seconds for now.
  final String weatherCondition; // e.g., "rainy", "sunny"
  final double moodScoreRaw; // For capturing potential raw input if applicable, though final score is int 1-100.

  const ReflectionData({
    required this.screenTimeSeconds,
    required this.weatherCondition,
    required this.moodScoreRaw,
  });

  factory ReflectionData.fromJson(Map<String, dynamic> json) => _$ReflectionDataFromJson(json);
  Map<String, dynamic> toJson() => _$ReflectionDataToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake, // Maps userId -> user_id, inputData -> input_data, moodScore -> mood_score
)
class Reflection {
  final String id; // Reflection ID
  final String userId; // User ID FK
  final ReflectionData inputData;
  final String narrative; // AI generated text
  final int moodScore; // Final calculated score (1-100)

  const Reflection({
    required this.id,
    required this.userId,
    required this.inputData,
    required this.narrative,
    required this.moodScore,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) => _$ReflectionFromJson(json);
  Map<String, dynamic> toJson() => _$ReflectionToJson(this);
}