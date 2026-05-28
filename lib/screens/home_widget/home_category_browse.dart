import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/categories_model.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';
import '../category_books_screen.dart';

class HomeCategoryBrowse extends StatelessWidget {
  const HomeCategoryBrowse({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryBooksScreen(
              category: Categories(id: '0', name: 'All', slug: 'all', description: '', isActive: 'true', createdAt: '', updatedAt: ''),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cs.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.category, color: cs.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('categories'),
                      style: TextStyle(
                        fontSize: context.sp(17),
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Browse all categories',
                      style: TextStyle(
                        fontSize: context.sp(13),
                        color: AppColors.iosGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.iosGray, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
