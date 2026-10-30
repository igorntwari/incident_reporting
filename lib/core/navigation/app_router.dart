import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/incidents/presentation/incident_details_screen.dart';
import '../../features/incidents/presentation/incident_form_screen.dart';
import '../../features/incidents/presentation/reports_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Bridges the Riverpod auth stream to go_router: any session change
  // (sign-in, sign-out, email verified) re-runs `redirect`.
  final authChanges = ValueNotifier(0);
  ref
    ..listen(authStateProvider, (_, _) => authChanges.value++)
    ..onDispose(authChanges.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authChanges,
    redirect: (_, state) => _guard(ref.read(authStateProvider), state),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          _tab(AppRoutes.home, const HomeScreen()),
          _tab(AppRoutes.reports, const ReportsScreen()),
          _tab(AppRoutes.profile, const ProfileScreen()),
        ],
      ),
      // Full-screen routes sit outside the shell so the bottom bar hides.
      GoRoute(
        path: AppRoutes.newReport,
        builder: (_, _) => const IncidentFormScreen(),
      ),
      GoRoute(
        path: '/incidents/:id',
        builder: (_, state) =>
            IncidentDetailsScreen(incidentId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                IncidentFormScreen(incidentId: state.pathParameters['id']),
          ),
        ],
      ),
    ],
  );
});

StatefulShellBranch _tab(String path, Widget screen) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (_, _) => screen)],
    );

/// Session gate: no session → login, unverified → verify screen,
/// verified user on an auth page → home. Returns `null` to stay put.
String? _guard(AsyncValue<User?> auth, GoRouterState state) {
  final location = state.matchedLocation;
  if (auth.isLoading && !auth.hasValue) return AppRoutes.splash;

  final user = auth.value;
  if (user == null) {
    return AppRoutes.public.contains(location) ? null : AppRoutes.login;
  }
  if (!user.emailVerified) {
    return location == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
  }
  final onEntryPage = AppRoutes.public.contains(location) ||
      location == AppRoutes.verifyEmail ||
      location == AppRoutes.splash;
  return onEntryPage ? AppRoutes.home : null;
}
