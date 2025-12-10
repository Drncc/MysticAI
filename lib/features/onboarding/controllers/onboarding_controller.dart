import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

class OnboardingState {
  final String name;
  final int? age;
  final int? height;
  final bool isAstrologyEnabled;

  const OnboardingState({
    this.name = '',
    this.age,
    this.height,
    this.isAstrologyEnabled = false,
  });

  OnboardingState copyWith({
    String? name,
    int? age,
    int? height,
    bool? isAstrologyEnabled,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      isAstrologyEnabled: isAstrologyEnabled ?? this.isAstrologyEnabled,
    );
  }
}

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() => const OnboardingState();

  void setName(String value) {
    state = state.copyWith(name: value.trim());
  }

  void setAge(int? value) {
    state = state.copyWith(age: value);
  }

  void setHeight(int? value) {
    state = state.copyWith(height: value);
  }

  void toggleAstrology(bool value) {
    state = state.copyWith(isAstrologyEnabled: value);
  }
}

