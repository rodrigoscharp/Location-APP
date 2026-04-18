import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../router/routes.dart';
import '../../auth/presentation/auth_provider.dart';
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
      backgroundColor: AppColors.paleGray,
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.coral)),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar perfil')),
        data: (profile) => CustomScrollView(
          slivers: [
            // Gradient header
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5A5F), Color(0xFFFF8087)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.white.withValues(alpha: 0.2),
                            backgroundImage: profile?.avatarUrl != null
                                ? CachedNetworkImageProvider(profile!.avatarUrl!)
                                : null,
                            child: profile?.avatarUrl == null
                                ? Text(
                                    profile?.initials ?? '?',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile?.displayName ?? 'Viajante',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bookings section
                    Text(
                      'Minhas reservas',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (user != null)
                      FutureBuilder<List<Booking>>(
                        future: ref
                            .read(bookingRepositoryProvider)
                            .getGuestBookings(user.id),
                        builder: (_, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.coral),
                            );
                          }
                          final bookings = snap.data ?? [];
                          if (bookings.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.lightGray),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.luggage_outlined,
                                      color: AppColors.mediumGray, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Nenhuma reserva ainda.',
                                    style: GoogleFonts.dmSans(
                                        color: AppColors.warmGray),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: bookings
                                .map((b) => _BookingTile(booking: b))
                                .toList(),
                          );
                        },
                      ),

                    const SizedBox(height: AppSpacings.xl),

                    // Menu items
                    _MenuSection(
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          label: 'Editar perfil',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.notifications_none_outlined,
                          label: 'Notificações',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.help_outline,
                          label: 'Ajuda',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Sign out
                    _MenuSection(
                      items: [
                        _MenuItem(
                          icon: Icons.logout,
                          label: 'Sair',
                          color: AppColors.error,
                          onTap: () async {
                            await ref.read(authRepositoryProvider).signOut();
                            if (context.mounted) context.go(Routes.login);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacings.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (item.color ?? AppColors.coral).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon,
                      color: item.color ?? AppColors.coral, size: 18),
                ),
                title: Text(
                  item.label,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    color: item.color ?? AppColors.charcoal,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.mediumGray,
                  size: 20,
                ),
                onTap: item.onTap,
              ),
              if (idx < items.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_outlined,
                color: AppColors.coral, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.checkIn.day}/${booking.checkIn.month} → ${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${booking.nights} noite${booking.nights > 1 ? 's' : ''} · ${booking.guestsCount} hóspede${booking.guestsCount > 1 ? 's' : ''}',
                  style: GoogleFonts.dmSans(
                      color: AppColors.warmGray, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: GoogleFonts.dmSans(
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
