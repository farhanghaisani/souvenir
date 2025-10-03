import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => supabase.auth.currentUser;

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return false;

      final response = await supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', userId)
          .single();

      return response['is_admin'] == true;
    } catch (e) {
      debugPrint('Error checking admin: $e');
      return false;
    }
  }

  // ✨ Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  // ✨ Update user name
  Future<bool> updateUserName(String name) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) return false;

      await supabase
          .from('profiles')
          .update({
            'name': name,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error updating name: $e');
      return false;
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Registrasi gagal: User tidak terbuat');
      }

      debugPrint('✅ User created: ${response.user!.id}');

      try {
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'is_admin': false,
          'created_at': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Profile created for: $fullName');
      } catch (e) {
        debugPrint('❌ Error creating profile: $e');
        throw Exception('Gagal membuat profil: $e');
      }
    } on AuthException catch (e) {
      debugPrint('❌ Auth error: ${e.message}');
      throw Exception('Error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Registrasi gagal: $e');
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal');
      }
    } on AuthException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      debugPrint('❌ Update password error: ${e.message}');
      throw Exception('Error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Gagal mengubah password');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'your-app://reset-password',
      );
    } on AuthException catch (e) {
      debugPrint('❌ Reset password error: ${e.message}');
      throw Exception('Gagal mengirim email: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}