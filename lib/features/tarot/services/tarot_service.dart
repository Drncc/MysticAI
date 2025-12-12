import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tekno_mistik/features/tarot/data/models/tarot_card_model.dart';
import 'package:tekno_mistik/features/tarot/data/tarot_deck.dart';

class TarotSelection {
  final TarotCard card;
  final int variantId;

  TarotSelection(this.card, this.variantId);
}

class TarotService {
  static const String _historyKey = 'tarot_history_v1';
  static const int _cooldownDays = 7;

  /// Draws a daily card with memory logic.
  /// [preferredVariant]: Optional. If provided (e.g. 3), attempts to select this variant if available for the card.
  Future<TarotSelection> drawDailyCard({int? preferredVariant}) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_historyKey) ?? [];
    
    // 1. Clean old history
    final now = DateTime.now();
    final cleanedHistory = history.where((entry) {
      final parts = entry.split('|');
      if (parts.length < 2) return false;
      final timestamp = int.tryParse(parts[1]) ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return now.difference(date).inDays < _cooldownDays;
    }).toList();

    final usedVariants = cleanedHistory.map((entry) => entry.split('|')[0]).toSet();
    final random = Random();
    
    // 3. Select Card & Logic
    TarotCard selectedCard = TarotDeck.majorArcana[random.nextInt(TarotDeck.majorArcana.length)];
    List<int> availableVariants = [];
    
    for (int v = 1; v <= selectedCard.variantCount; v++) {
      if (!usedVariants.contains('${selectedCard.id}_$v')) {
        availableVariants.add(v);
      }
    }
    
    int selectedVariant = 1;
    
    if (availableVariants.isNotEmpty) {
      // Logic: If preferredVariant is requested AND available, use it.
      if (preferredVariant != null && availableVariants.contains(preferredVariant)) {
        selectedVariant = preferredVariant;
      } else {
        selectedVariant = availableVariants[random.nextInt(availableVariants.length)];
      }
    } else {
      // Fallback: If all used, pick random or preferred if valid
      if (preferredVariant != null && preferredVariant <= selectedCard.variantCount) {
         selectedVariant = preferredVariant;
      } else {
         selectedVariant = random.nextInt(selectedCard.variantCount) + 1;
      }
    }

    // 4. Save Selection
    final newEntry = '${selectedCard.id}_$selectedVariant|${now.millisecondsSinceEpoch}';
    cleanedHistory.add(newEntry);
    await prefs.setStringList(_historyKey, cleanedHistory);

    return TarotSelection(selectedCard, selectedVariant);
  }
}
