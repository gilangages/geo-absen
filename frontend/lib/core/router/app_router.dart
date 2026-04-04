import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/register/register_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/leave/leave_form_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      name: 'profile_edit',
      builder: (context, state) {
        final userData = state.extra as Map<String, dynamic>;
        return EditProfileScreen(userData: userData);
      },
    ),
    GoRoute(
      path: '/leave/form',
      name: 'leave_form',
      builder: (context, state) => const LeaveFormScreen(),
    ),
  ],
);
