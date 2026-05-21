import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';
import '../utils/app_localizations.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('settings'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildAppearanceSection(context, loc),
          const SizedBox(height: 16),
          _buildLanguageSection(context, loc),
          const SizedBox(height: 16),
          _buildGeneralSection(context, loc),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.iosGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppLocalizations loc) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(loc.translate('appearance'), cs),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return _buildSettingsRow(
                    context,
                    icon: settings.isDark ? Icons.dark_mode : Icons.light_mode,
                    title: loc.translate('dark_mode'),
                    subtitle: loc.translate('toggle_theme'),
                    trailing: Switch(
                      value: settings.isDark,
                      onChanged: (_) => settings.toggleTheme(),
                      activeThumbColor: cs.primary,
                    ),
                  );
                },
              ),
              Divider(
                height: 0,
                indent: 52,
                color: isDark
                    ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
                    : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return _buildSettingsRow(
                    context,
                    icon: Icons.text_fields,
                    title: loc.translate('font_size'),
                    subtitle: loc.translate('adjust_font'),
                    trailing: _buildFontSizeSelector(context, settings, loc, cs, isDark),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSelector(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations loc,
    ColorScheme cs,
    bool isDark,
  ) {
    const options = [
      ('A', 0.85),
      ('A', 1.0),
      ('A', 1.15),
      ('A', 1.3),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((opt) {
        final selected = settings.fontScale == opt.$2;
        final sizes = [11.0, 14.0, 17.0, 20.0];
        final idx = options.toList().indexOf(opt);
        return GestureDetector(
          onTap: () => settings.setFontScale(opt.$2),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary
                  : (isDark ? AppColors.iosGrayDark4 : AppColors.iosGray6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: sizes[idx],
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? Colors.white : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations loc) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(loc.translate('language'), cs),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return RadioGroup<AppLocalePreference>(
                    groupValue: settings.localePreference,
                    onChanged: (val) {
                      if (val != null) settings.setLocale(val);
                    },
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          context,
                          icon: Icons.language,
                          title: 'English',
                          subtitle: loc.translate('english'),
                          trailing: Radio<AppLocalePreference>(
                            value: AppLocalePreference.english,
                          ),
                          onTap: () => settings.setLocale(AppLocalePreference.english),
                        ),
                        Divider(
                          height: 0,
                          indent: 52,
                          color: isDark
                              ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
                              : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
                        ),
                        _buildSettingsRow(
                          context,
                          icon: Icons.language,
                          title: '\u1797\u17b6\u179f\u17b6\u1781\u17d2\u1798\u17c2\u179a',
                          subtitle: loc.translate('khmer'),
                          trailing: Radio<AppLocalePreference>(
                            value: AppLocalePreference.khmer,
                          ),
                          onTap: () => settings.setLocale(AppLocalePreference.khmer),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSection(BuildContext context, AppLocalizations loc) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(loc.translate('general'), cs),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildSettingsRow(
            context,
            icon: Icons.info_outline,
            title: loc.translate('about'),
            subtitle: loc.translate('version'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            showChevron: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.iosGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? (showChevron ? Icon(Icons.chevron_right, color: AppColors.iosGray3, size: 18) : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
