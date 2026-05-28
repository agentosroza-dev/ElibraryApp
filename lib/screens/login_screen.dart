import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:email_validator/email_validator.dart';
import '../utils/transitions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/font_scale.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(fadeRoute(const MainShell()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? loc.translate('login_failed')),
          backgroundColor: AppColors.iosRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/PAC_location.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(color: AppColors.iosBackgroundDark.withValues(alpha: 0.2)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.iosBackgroundDark.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/PAC_E-Library.png',
                            height: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 150),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    loc.translate('welcome_back'),
                                    style: TextStyle(
                                      fontSize: context.sp(24),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.translate('sign_in_continue'),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: context.sp(15),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  _buildField(
                                    controller: _emailController,
                                    hint: loc.translate('email'),
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return loc.translate('enter_email');
                                      }
                                      if (!EmailValidator.validate(v)) {
                                        return loc.translate('valid_email');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    controller: _passwordController,
                                    hint: loc.translate('password'),
                                    icon: Icons.lock_outlined,
                                    obscure: _obscurePassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return loc.translate('enter_password');
                                      }
                                      if (v.length < 6) {
                                        return loc.translate('password_min');
                                      }
                                      return null;
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        loc.translate('forgot_password'),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.65,
                                          ),
                                          fontSize: context.sp(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Consumer<AuthProvider>(
                                    builder: (context, auth, _) {
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: auth.isLoading
                                              ? null
                                              : _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.iosBlue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: auth.isLoading
                                              ? const SpinKitFadingCircle(
                                                  color: Colors.white,
                                                  size: 24,
                                                )
                                                  : Text(
                                                      loc.translate('sign_in'),
                                                      style: TextStyle(
                                                        fontSize: context.sp(17),
                                                        fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          loc.translate('choose_language'),
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: context.sp(13),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Consumer<SettingsProvider>(
                                    builder: (context, settings, _) {
                                      final isEn =
                                          settings.localePreference ==
                                          AppLocalePreference.english;
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                           GestureDetector(
                                             onTap: () => settings.setLocale(
                                               AppLocalePreference.english,
                                             ),
                                             child: Container(
                                               padding:
                                                   const EdgeInsets.symmetric(
                                                     horizontal: 20,
                                                     vertical: 10,
                                                   ),
                                               decoration: BoxDecoration(
                                                 color: isEn
                                                     ? Colors.white.withValues(
                                                         alpha: 0.15,
                                                       )
                                                     : Colors.transparent,
                                                 borderRadius:
                                                     BorderRadius.circular(10),
                                                 border: Border.all(
                                                   color: Colors.white
                                                       .withValues(alpha: 0.2),
                                                 ),
                                               ),
                                               child: Text(
                                                 loc.translate('english'),
                                                 style: TextStyle(
                                                   color: isEn
                                                       ? Colors.white
                                                       : Colors.white.withValues(
                                                           alpha: 0.55,
                                                         ),
                                                   fontWeight: isEn
                                                       ? FontWeight.w700
                                                       : FontWeight.w500,
                                                   fontSize: context.sp(14),
                                                 ),
                                               ),
                                             ),
                                           ),
                                           const SizedBox(width: 12),
                                           GestureDetector(
                                             onTap: () => settings.setLocale(
                                               AppLocalePreference.khmer,
                                             ),
                                             child: Container(
                                               padding:
                                                   const EdgeInsets.symmetric(
                                                     horizontal: 20,
                                                     vertical: 10,
                                                   ),
                                               decoration: BoxDecoration(
                                                 color: !isEn
                                                     ? Colors.white.withValues(
                                                         alpha: 0.15,
                                                       )
                                                     : Colors.transparent,
                                                 borderRadius:
                                                     BorderRadius.circular(10),
                                                 border: Border.all(
                                                   color: Colors.white
                                                       .withValues(alpha: 0.2),
                                                 ),
                                               ),
                                               child: Text(
                                                 loc.translate('khmer'),
                                                 style: TextStyle(
                                                   color: !isEn
                                                       ? Colors.white
                                                       : Colors.white.withValues(
                                                           alpha: 0.55,
                                                         ),
                                                   fontWeight: !isEn
                                                       ? FontWeight.w700
                                                       : FontWeight.w500,
                                                   fontSize: context.sp(14),
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                      loc.translate('no_account'),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
                                        fontSize: context.sp(14),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        loc.translate('sign_up'),
                                        style: TextStyle(
                                          color: AppColors.iosBlue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: context.sp(14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: context.sp(16)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.45),
          size: 20,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.iosBlue.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.iosRed.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.iosRed.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
