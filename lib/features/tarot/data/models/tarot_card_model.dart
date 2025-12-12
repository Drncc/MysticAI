import 'dart:math';

class TarotCard {
  final int id;
  final String name;
  final String codeName;
  final int variantCount;
  final String meaning;

  const TarotCard({
    required this.id,
    required this.name,
    required this.codeName,
    required this.variantCount,
    required this.meaning,
  });

  /// Generates a random image path from available variants
  /// Format: assets/tarot/{id}_{codeName}_{1..variantCount}.jpg
  String get randomImagePath {
    if (variantCount <= 1) {
      return 'assets/tarot/${id}_${codeName}_1.jpg';
    }
    final randomInfo = Random();
    final variant = randomInfo.nextInt(variantCount) + 1; // 1 to variantCount
    return 'assets/tarot/${id}_${codeName}_$variant.jpg';
  }
}
