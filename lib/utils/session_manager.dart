import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyEmail = 'user_email';
  static const _keyUid = 'user_uid';

  /// Simpan sesi user (UID dan email)
  static Future<void> saveSession({
    required String uid,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyEmail, email);
  }

  /// Ambil UID
  static Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  /// Ambil email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Hapus semua session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUid);
    await prefs.remove(_keyEmail);
  }
}
