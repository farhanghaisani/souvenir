import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<UserProfile?> getProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      await supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }

  Future<void> createProfile({
    required String userId,
    required String fullName,
  }) async {
    try {
      await supabase.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal membuat profil: $e');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak ditemukan');

      // Baca file sebagai bytes
      final bytes = await imageFile.readAsBytes();
      
      // Hapus foto lama jika ada
      final currentProfile = await getProfile();
      if (currentProfile?.profileImageUrl != null) {
        try {
          final url = currentProfile!.profileImageUrl!;
          final fileName = url.split('/').last.split('?').first;
          await supabase.storage
              .from('profiles')
              .remove(['$userId/$fileName']);
        } catch (e) {
          debugPrint('Error deleting old image: $e');
        }
      }

      // Upload foto baru
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      // Upload menggunakan uploadBinary untuk Uint8List
      await supabase.storage
          .from('profiles')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      // Get public URL
      final imageUrl = supabase.storage
          .from('profiles')
          .getPublicUrl(filePath);

      // Update profile dengan URL foto
      await supabase.from('profiles').update({
        'profile_image_url': imageUrl,
      }).eq('id', userId);

      return imageUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      throw Exception('Gagal upload foto: $e');
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User tidak ditemukan');

      final currentProfile = await getProfile();
      if (currentProfile?.profileImageUrl != null) {
        try {
          final url = currentProfile!.profileImageUrl!;
          final fileName = url.split('/').last.split('?').first;
          await supabase.storage
              .from('profiles')
              .remove(['$userId/$fileName']);
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }

        // Update profile, hapus URL foto
        await supabase.from('profiles').update({
          'profile_image_url': null,
        }).eq('id', userId);
      }
    } catch (e) {
      throw Exception('Gagal hapus foto: $e');
    }
  }
}