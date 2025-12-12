import 'package:shared_preferences/shared_preferences.dart';

class LimitService {
  static const int _freeMessageLimit = 3;
  static const int _premiumMessageLimit = 15;
  static const int _freeCardLimit = 1;
  static const int _premiumCardLimit = 3;

  static final LimitService _instance = LimitService._internal();
  factory LimitService() => _instance;
  LimitService._internal();

  bool _isPremium = false;
  int _dailyMessageCount = 0;
  int _dailyCardCount = 0;
  String _lastResetDate = "";

  bool get isPremium => _isPremium;
  int get remainingMessages => (_isPremium ? _premiumMessageLimit : _freeMessageLimit) - _dailyMessageCount;
  int get remainingCards => (_isPremium ? _premiumCardLimit : _freeCardLimit) - _dailyCardCount;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _dailyMessageCount = prefs.getInt('daily_message_count') ?? 0;
    _dailyCardCount = prefs.getInt('daily_card_count') ?? 0;
    _lastResetDate = prefs.getString('last_reset_date') ?? "";

    _checkAndReset();
  }

  void _checkAndReset() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    if (_lastResetDate != todayStr) {
      _dailyMessageCount = 0;
      _dailyCardCount = 0;
      _lastResetDate = todayStr;
      _saveState();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', _isPremium);
    await prefs.setInt('daily_message_count', _dailyMessageCount);
    await prefs.setInt('daily_card_count', _dailyCardCount);
    await prefs.setString('last_reset_date', _lastResetDate);
  }

  bool get canSendMessage {
    _checkAndReset(); // Ensure fresh state
    final limit = _isPremium ? _premiumMessageLimit : _freeMessageLimit;
    return _dailyMessageCount < limit;
  }

  bool get canDrawCard {
    _checkAndReset(); // Ensure fresh state
    final limit = _isPremium ? _premiumCardLimit : _freeCardLimit;
    return _dailyCardCount < limit;
  }

  Future<void> incrementMessage() async {
    _dailyMessageCount++;
    await _saveState();
  }

  Future<void> incrementCard() async {
    _dailyCardCount++;
    await _saveState();
  }

  Future<void> upgradeToPremium() async {
    _isPremium = true;
    await _saveState();
  }
  
  // Debug/Dev only
  Future<void> resetLimitsManually() async {
    _dailyMessageCount = 0;
    _dailyCardCount = 0;
    await _saveState();
  }
}
