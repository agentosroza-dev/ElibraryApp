import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/transitions.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/font_scale.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.of(context).pushReplacement(fadeRoute(const MainShell()));
    } else {
      Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF007AFF), Color(0xFF1C1C1E)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/PAC_E-Library.png',
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 300),
              child: Text(
                loc.translate('app_name'),
                style: TextStyle(
                  fontSize: context.sp(24),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 500),
              child: Text(
                loc.translate('discover_knowledge'),
                style: TextStyle(
                  fontSize: context.sp(16),
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isInitializing) {
                  return FadeIn(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 800),
                    child: const SpinKitFadingCircle(
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
