import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../utils/app_localizations.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context, cs, isDark, auth),
              _buildStatsRow(context, cs, isDark),
              _buildMenuSection(context, cs, isDark),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme cs, bool isDark, AuthProvider auth) {
    final loc = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 40,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosGrayDark6 : AppColors.iosGray6,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
                : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: FadeIn(
        duration: const Duration(milliseconds: 600),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: cs.primary.withValues(alpha: 0.15),
                backgroundImage: auth.userPhoto != null
                    ? CachedNetworkImageProvider(auth.userPhoto!)
                    : null,
                child: auth.userPhoto == null
                    ? Icon(Icons.person, size: 44, color: cs.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.userName.isNotEmpty ? auth.userName : loc.translate('user'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              auth.userEmail,
              style: TextStyle(
                color: AppColors.iosGray,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const EditProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: Text(loc.translate('edit_profile')),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          _buildStatCard(context, loc.translate('books'), '12', cs, isDark),
          const SizedBox(width: 10),
          _buildStatCard(context, loc.translate('favorites'), '8', cs, isDark),
          const SizedBox(width: 10),
          _buildStatCard(context, loc.translate('hours'), '47', cs, isDark),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, ColorScheme cs, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.iosGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuGroup(context, [
            _MenuItemData(
              icon: Icons.settings_outlined,
              title: loc.translate('settings'),
              subtitle: loc.translate('choose_language'),
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const SettingsScreen(),
                ),
              ),
            ),
            _MenuItemData(
              icon: Icons.download_outlined,
              title: loc.translate('downloads'),
              subtitle: loc.translate('manage_offline'),
            ),
            _MenuItemData(
              icon: Icons.notifications_outlined,
              title: loc.translate('notifications'),
              subtitle: loc.translate('reading_reminders'),
            ),
          ], cs, isDark),
          const SizedBox(height: 16),
          _buildMenuGroup(context, [
            _MenuItemData(
              icon: Icons.help_outline,
              title: loc.translate('help_support'),
              subtitle: loc.translate('faqs_contact'),
            ),
            _MenuItemData(
              icon: Icons.info_outline,
              title: loc.translate('about'),
              subtitle: loc.translate('version'),
            ),
          ], cs, isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.iosRed),
              label: Text(
                loc.translate('sign_out'),
                style: const TextStyle(color: AppColors.iosRed),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.iosRed.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<_MenuItemData> items, ColorScheme cs, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _buildMenuItem(context, item, cs),
              if (!isLast)
                Divider(
                  height: 0,
                  indent: 52,
                  color: isDark
                      ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
                      : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItemData item, ColorScheme cs) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: AppColors.iosGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.iosGray3, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}
