import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class MyAccountController {
  final _client = Supabase.instance.client;

  /// NOTE:
  /// This implementation *assumes* you have a `users` table with a `phone` column
  /// that is unique per user. If you prefer to identify users differently,
  /// change the query in getUser / updateUser / deleteUser accordingly.
  ///
  /// Example alternatives:
  /// - identify by email: .eq('email', currentUserEmail)
  /// - identify by auth id: .eq('auth_id', supabase.auth.currentUser!.id)
  /// If you have neither, we can store auth id in a column 'auth_id' and use that.

  Future<UserModel?> getUserByPhone(String phone) async {
    final res = await _client
        .from('users')
        .select()
        .eq('phone', phone)
        .maybeSingle();
    if (res == null) return null;
    return UserModel.fromMap(res as Map<String, dynamic>);
  }

  /// Try to load current user using Supabase auth metadata (phone) fallback.
  Future<UserModel?> loadCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    // Try to read phone from user metadata (if you saved it during signup)
    final meta = user.userMetadata ?? {};
    final phoneFromMeta = meta['phone'] as String?;
    if (phoneFromMeta != null && phoneFromMeta.isNotEmpty) {
      final byPhone = await getUserByPhone(phoneFromMeta);
      if (byPhone != null) return byPhone;
    }

    // If metadata not available, try to find user by a 'phone' that you pass externally;
    // caller can call getUserByPhone(phone) directly.

    // As a last resort, try to find a row that matches the user's email (if exists)
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      final res = await _client
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (res != null) return UserModel.fromMap(res as Map<String, dynamic>);
    }

    return null;
  }

  Future<bool> updateUserByPhone(String phone, UserModel updated) async {
    final res = await _client
        .from('users')
        .update(updated.toMap())
        .eq('phone', phone);
    return res.error == null;
  }

  Future<bool> deleteUserByPhone(String phone) async {
    final res =
        await _client.from('users').delete().eq('phone', phone);
    return res.error == null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}