import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/app_localizations.dart';
import '../utils/font_scale.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('about'),
          style: TextStyle(fontSize: context.sp(17), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildAppIcon(cs, isDark),
            const SizedBox(height: 16),
            Text(
              loc.translate('app_name'),
              style: TextStyle(
                fontSize: context.sp(24),
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${loc.translate('version')} 1.0.0',
              style: TextStyle(fontSize: context.sp(14), color: AppColors.iosGray),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(context, cs, isDark, loc),
            const SizedBox(height: 16),
            _buildDescriptionCard(context, cs, isDark, loc),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(ColorScheme cs, bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.auto_stories, size: 40, color: Colors.white),
    );
  }

  Widget _buildInfoCard(BuildContext context, ColorScheme cs, bool isDark, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.person, 'Developer', 'PAC Team', cs),
          Divider(height: 0, indent: 52, color: isDark ? AppColors.iosSeparatorDark.withValues(alpha: 0.3) : AppColors.iosSeparatorLight.withValues(alpha: 0.08)),
          _buildInfoRow(context, Icons.email_outlined, 'Email', 'support@pac.edu.kh', cs),
          Divider(height: 0, indent: 52, color: isDark ? AppColors.iosSeparatorDark.withValues(alpha: 0.3) : AppColors.iosSeparatorLight.withValues(alpha: 0.08)),
          _buildInfoRow(context, Icons.language, 'Website', 'www.pac.edu.kh', cs),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, ColorScheme cs) {
    return Padding(
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
            child: Icon(icon, size: 16, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: context.sp(12), color: AppColors.iosGray),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: context.sp(15), fontWeight: FontWeight.w500, color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, ColorScheme cs, bool isDark, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                loc.translate('about'),
                style: TextStyle(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              'PAC E-Library is a digital reading platform that provides students and faculty with access to a vast collection of academic resources, e-books, and research materials anytime, anywhere.',
              style: TextStyle(
                fontSize: context.sp(14),
              color: AppColors.iosGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
