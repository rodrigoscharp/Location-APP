import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../router/routes.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../booking/data/booking_repository.dart';
import '../../booking/domain/booking.dart';
import '../../booking/presentation/booking_provider.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.coral)),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar perfil')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacings.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.coral.withOpacity(0.15),
                      backgroundImage: profile?.avatarUrl != null
                          ? CachedNetworkImageProvider(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? Text(
                              profile?.initials ?? '?',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.coral,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacings.base),
                    Text(
                      profile?.displayName ?? 'Viajante',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: AppColors.warmGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacings.xl),
              const Text(
                'Minhas reservas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacings.base),
              if (user != null)
                FutureBuilder<List<Booking>>(
                  future: ref
                      .read(bookingRepositoryProvider)
                      .getGuestBookings(user.id),
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.coral),
                      );
                    }
                    final bookings = snap.data ?? [];
                    if (bookings.isEmpty) {
                      return const Text(
                        'Nenhuma reserva ainda.',
                        style: TextStyle(color: AppColors.warmGray),
                      );
                    }
                    return Column(
                      children: bookings.map((b) => _BookingTile(booking: b)).toList(),
                    );
                  },
                ),
              const SizedBox(height: AppSpacings.xl),
              const Divider(),
              // Sign out
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Sair',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go(Routes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;

  const _BookingTile({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.pending:
        return 'Pendente';
      case BookingStatus.cancelled:
        return 'Cancelada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.checkIn.day}/${booking.checkIn.month} → ${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${booking.nights} noite${booking.nights > 1 ? 's' : ''} · ${booking.guestsCount} hóspede${booking.guestsCount > 1 ? 's' : ''}',
                  style: const TextStyle(color: AppColors.warmGray, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: _statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
