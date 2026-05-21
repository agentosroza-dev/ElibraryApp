import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../utils/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _mapUrl =
      'https://www.google.com/maps/place/Police+Academy+of+Cambodia/@11.4886293,105.1089715,18z/data=!4m6!3m5!1s0x310be34cecf78365:0x504debb8dfa2bcd5!8m2!3d11.4884953!4d105.1102912!16s%2Fg%2F11r8c1vvc?entry=ttu&g_ep=EgoyMDI2MDUxMy4wIKXMDSoASAFQAw%3D%3D';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('help_support'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildContactCard(context, cs, isDark),
            const SizedBox(height: 16),
            _buildMapCard(context, cs, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildContactItem(
            context,
            cs,
            icon: Icons.phone_in_talk,
            label: 'Hotline',
            value: '023 999 999',
            onTap: () => _launchUrl('tel:023999999', context),
          ),
          _divider(cs, isDark),
          _buildContactItem(
            context,
            cs,
            icon: Icons.phone,
            label: 'Phone',
            value: '023 888 888',
            onTap: () => _launchUrl('tel:023888888', context),
          ),
          _divider(cs, isDark),
          _buildContactItem(
            context,
            cs,
            icon: Icons.chat_bubble_outline,
            label: 'Messenger',
            value: 'm.me/PACE-Library',
            onTap: () => _launchUrl('https://m.me/PACE-Library', context),
          ),
          _divider(cs, isDark),
          _buildContactItem(
            context,
            cs,
            icon: Icons.send,
            label: 'Telegram',
            value: '@PACELibrary',
            onTap: () => _launchUrl('https://t.me/PACELibrary', context),
          ),
          _divider(cs, isDark),
          _buildContactItem(
            context,
            cs,
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'support@pac.edu.kh',
            onTap: () => _launchUrl('mailto:support@pac.edu.kh', context),
          ),
          _divider(cs, isDark),
          _buildContactItem(
            context,
            cs,
            icon: Icons.language,
            label: 'Website',
            value: 'www.pac.edu.kh',
            onTap: () => _launchUrl('https://www.pac.edu.kh', context),
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme cs, bool isDark) {
    return Divider(
      height: 0,
      indent: 52,
      color: isDark
          ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
          : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    ColorScheme cs, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: AppColors.iosGray),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
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

  Widget _buildMapCard(BuildContext context, ColorScheme cs, bool isDark) {
    return GestureDetector(
      onTap: () => _launchUrl(_mapUrl, context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: AppColors.iosRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Police Academy of Cambodia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phnom Penh, Cambodia',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.iosGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: double.infinity,
                    color: cs.primary.withValues(alpha: 0.12),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppColors.iosRed,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Open in Google Maps',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      }
    }
  }
}
