import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/role.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class RoleGuard extends StatelessWidget {
  final UserRole requiredRole; final Widget child;
  const RoleGuard({super.key, required this.requiredRole, required this.child});
  @override Widget build(BuildContext context){
    final auth = context.watch<AuthState>();
    if (!auth.isAuthenticated) return const LoginPage();
    if (auth.role != requiredRole) {
      return const Scaffold(body: Center(child: Text('Unauthorized')));
    }
    return child;
  }
}
