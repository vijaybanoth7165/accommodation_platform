import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AccommodationPlatformApp());
}

class AccommodationPlatformApp extends StatefulWidget {
  const AccommodationPlatformApp({super.key});

  @override
  State<AccommodationPlatformApp> createState() => _AccommodationPlatformAppState();
}

class _AccommodationPlatformAppState extends State<AccommodationPlatformApp> {
  bool _isLoggedIn = false;

  void _handleLogin() {
    setState(() => _isLoggedIn = true);
  }

  void _handleLogout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accommodation Management Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoggedIn
          ? OwnerDashboardScreen(onLogout: _handleLogout)
          : LoginScreen(onLoginSuccess: _handleLogin),
    );
  }
}
