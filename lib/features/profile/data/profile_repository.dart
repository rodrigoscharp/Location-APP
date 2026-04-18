import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<Profile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromJson(data);
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isEmpty) return;
    await _client.from('profiles').update(updates).eq('id', userId);
  }

  Future<String?> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String extension,
  }) async {
    final path = '$userId/avatar.$extension';
    await _client.storage.from('avatars').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }
}
