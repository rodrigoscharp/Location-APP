import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(user.id);
});
