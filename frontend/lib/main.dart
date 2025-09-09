import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'models/role.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_home.dart';
import 'pages/teacher_home.dart';
import 'pages/student_home.dart';
import 'pages/teacher_analytics.dart';
import 'pages/admin_manage_users.dart';

void main() {
  runApp(const ThinkStrikeApp());
}

class ThinkStrikeApp extends StatelessWidget {
  const ThinkStrikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState()..init(),
      child: Consumer<AuthState>(builder: (context, auth, _) {
        final router = GoRouter(
          initialLocation: '/',
          refreshListenable: auth,
          routes: [
            GoRoute(path: '/', builder: (_, __) => const SplashPage()),
            GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
            GoRoute(path: '/student', builder: (_, __) => const StudentHomePage()),
            GoRoute(path: '/teacher', builder: (_, __) => const TeacherHomePage()),
            GoRoute(path: '/admin', builder: (_, __) => const AdminHomePage()),
            GoRoute(path: '/teacher/analytics', builder: (_, __) => const TeacherAnalyticsPage()),
            GoRoute(path: '/admin/users', builder: (_, __) => const AdminManageUsersPage()),
          ],
          redirect: (context, state) {
            final isAuth = auth.isAuthenticated;
            final role = auth.role;
            final loc = state.uri.toString();
            // Splash can decide
            if (loc == '/') {
              if (!isAuth) return '/login';
              switch (role) {
                case UserRole.admin: return '/admin';
                case UserRole.teacher: return '/teacher';
                case UserRole.student: return '/student';
                default: return '/login';
              }
            }
            // Role-based guards
            if (!isAuth && loc != '/login') return '/login';
            if (isAuth) {
              if (loc.startsWith('/admin') && role != UserRole.admin) return '/student';
              if (loc.startsWith('/teacher') && role != UserRole.teacher) return '/student';
            }
            return null;
          },
        );

        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown, brightness: Brightness.light),
          useMaterial3: true,
        );

        return MaterialApp.router(
          title: 'ThinkStrike',
          theme: theme,
          routerConfig: router,
        );
      }),
    );
  }
}
