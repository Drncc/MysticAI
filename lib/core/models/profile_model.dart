import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class BioMetrics {
  final int age;
  final int height; // Height in cm

  const BioMetrics({required this.age, required this.height});

  factory BioMetrics.fromJson(Map<String, dynamic> json) => _$BioMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$BioMetricsToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake, // Maps digitalConsent -> digital_consent, bioMetrics -> bio_metrics
)
class AppProfile {
  final String id; // Corresponds to Supabase Auth User ID (UUID)
  final String username;
  final bool digitalConsent;
  final BioMetrics bioMetrics;

  const AppProfile({
    required this.id,
    required this.username,
    required this.digitalConsent,
    required this.bioMetrics,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) => _$AppProfileFromJson(json);
  Map<String, dynamic> toJson() => _$AppProfileToJson(this);
}