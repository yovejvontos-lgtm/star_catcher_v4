import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// الحفظ المحلي: أفضل نتيجة.
class Save extends ChangeNotifier {
  Save._();

  static final Save instance = Save._();

  int best = 0;

  Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      best = p.getInt('best_v1') ?? 0;
    } catch (_) {}
    notifyListeners();
  }

  /// يحفظ النتيجة إن كانت أفضل. يرجع true إذا كانت رقماً قياسياً جديداً.
  Future<bool> submit(int score) async {
    if (score <= best) {
      return false;
    }
    best = score;
    notifyListeners();
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      await p.setInt('best_v1', best);
    } catch (_) {}
    return true;
  }
}
