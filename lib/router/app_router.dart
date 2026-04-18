import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/listings/presentation/listings_screen.dart';
import '../features/listings/presentation/listing_detail_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/chat/presentation/chat_list_screen.dart';
import '../features/chat/presentation/chat_room_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/booking/presentation/checkout_screen.dart';
import '../features/booking/presentation/payment_screen.dart';
import '../features/booking/presentation/booking_confirmation_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);

  ref.listen(authStateProvider, (_, next) {
    authNotifier.value = next.valueOrNull?.session != null;
  });

  return GoRouter(
    initialLocation: Routes.explore,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.value;
      final loc = state.matchedLocation;

      const protectedPrefixes = [
        Routes.favorites,
        Routes.inbox,
        Routes.profile,
      ];

      final isProtected = protectedPrefixes.any((p) => loc.startsWith(p));

      if (!isLoggedIn && isProtected) {
        return '${Routes.login}?redirect=$loc';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/confirmation/:bookingId',
        builder: (_, state) => BookingConfirmationScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.explore,
              builder: (_, __) => const ListingsScreen(),
              routes: [
                GoRoute(
                  path: 'listing/:id',
                  builder: (_, state) => ListingDetailScreen(
                    listingId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'checkout',
                      builder: (_, state) => CheckoutScreen(
                        listingId: state.pathParameters['id']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'payment/:bookingId',
                          builder: (_, state) => PaymentScreen(
                            bookingId: state.pathParameters['bookingId']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.map,
              builder: (_, __) => const MapScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.favorites,
              builder: (_, __) => const FavoritesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.inbox,
              builder: (_, __) => const ChatListScreen(),
              routes: [
                GoRoute(
                  path: 'chat/:convId',
                  builder: (_, state) => ChatRoomScreen(
                    conversationId: state.pathParameters['convId']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.profile,
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppScaffold({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
      ),
    );
  }
}
