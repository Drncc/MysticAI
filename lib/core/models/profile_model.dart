import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class AppProfile {
  final String id;
  final String? username;
  @JsonKey(name: 'digital_consent')
  final bool digitalConsent;
  @JsonKey(name: 'bio_metrics')
  final BioMetrics bioMetrics;

  const AppProfile({
    required this.id,
    this.username,
    required this.digitalConsent,
    required this.bioMetrics,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) => _$AppProfileFromJson(json);
  Map<String, dynamic> toJson() => _$AppProfileToJson(this);
}

@JsonSerializable()
class BioMetrics {
  final int age;
  final int height;
  final int weight;

  const BioMetrics({
    required this.age,
    required this.height,
    required this.weight,
  });

  factory BioMetrics.fromJson(Map<String, dynamic> json) => _$BioMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$BioMetricsToJson(this);
}