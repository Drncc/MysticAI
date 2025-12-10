import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tekno_mistik/core/constants/barnum_phrases.dart';
import 'package:tekno_mistik/features/onboarding/controllers/onboarding_controller.dart';

part 'dashboard_controller.g.dart';

class DashboardState {
  final String? name;
  final int? age;
  final int? height;
  final bool? isAstrologyEnabled;
  final String weatherCondition;
  final int humidity;
  final String screenTime;
  final String dailyInsight;

  DashboardState({
    this.name,
    this.age,
    this.height,
    this.isAstrologyEnabled,
    required this.weatherCondition,
    required this.humidity,
    required this.screenTime,
    required this.dailyInsight,
  });

  DashboardState copyWith({
    String? name,
    int? age,
    int? height,
    bool? isAstrologyEnabled,
    String? weatherCondition,
    int? humidity,
    String? screenTime,
    String? dailyInsight,
  }) {
    return DashboardState(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      isAstrologyEnabled: isAstrologyEnabled ?? this.isAstrologyEnabled,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      humidity: humidity ?? this.humidity,
      screenTime: screenTime ?? this.screenTime,
      dailyInsight: dailyInsight ?? this.dailyInsight,
    );
  }
}

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    final onboardingState = ref.watch(onboardingControllerProvider);
    final name = onboardingState.name;
    final age = onboardingState.age;
    final height = onboardingState.height;
    final isAstrologyEnabled = onboardingState.isAstrologyEnabled;

    return DashboardState(
      name: name,
      age: age,
      height: height,
      isAstrologyEnabled: isAstrologyEnabled,
      weatherCondition: _generateMockWeatherCondition(),
      humidity: _generateMockHumidity(),
      screenTime: _generateMockScreenTime(),
      dailyInsight: _generateBarnumInsight(),
    );
  }

  String _generateMockWeatherCondition() {
    final conditions = ['Rainy', 'Cloudy', 'Clear', 'Stormy', 'Mystic Fog'];
    return conditions[Random().nextInt(conditions.length)];
  }

  int _generateMockHumidity() {
    return Random().nextInt(100); // 0-99%
  }

  String _generateMockScreenTime() {
    final hours = Random().nextInt(8); // 0-7 hours
    final minutes = Random().nextInt(60); // 0-59 minutes
    return '${hours}h ${minutes}m';
  }

  String _generateBarnumInsight() {
    final phrases = BarnumPhrases.phrases;
    return phrases[Random().nextInt(phrases.length)];
  }
}