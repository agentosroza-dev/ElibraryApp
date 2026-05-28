import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/categories_model.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';
import '../category_books_screen.dart';

const Map<String, IconData> _categoryIcons = {
  'fiction': Icons.auto_stories,
  'science': Icons.science,
  'history': Icons.history_edu,
  'technology': Icons.computer,
  'art': Icons.palette,
  'philosophy': Icons.psychology,
  'mathematics': Icons.calculate,
  'education': Icons.school,
  'literature': Icons.menu_book,
  'programming': Icons.code,
  'business': Icons.business_center,
  'self-help': Icons.self_improvement,
  'health': Icons.favorite,
  'travel': Icons.flight,
  'religion': Icons.church,
  'comics': Icons.chat_bubble,
  'children': Icons.toys,
  'reference': Icons.library_books,
  'nature': Icons.forest,
};

class HomeCategories extends StatelessWidget {
  final List<Categories> cats;

  const HomeCategories({super.key, required this.cats});

  @override
  Widget build(BuildContext context) {
    if (cats.isEmpty) return const SizedBox.shrink();
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('categories'),
              style: TextStyle(
                fontSize: context.sp(22),
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              loc.translate('see_all'),
              style: TextStyle(
                color: cs.primary,
                fontSize: context.sp(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cats.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _HomeCategoryChip(label: loc.translate('all'), icon: Icons.explore, onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CategoryBooksScreen(category: Categories(id: '0', name: 'All', slug: 'all', description: '', isActive: 'true', createdAt: '', updatedAt: '')),
                  ));
                });
              }
              final cat = cats[index - 1];
              final icon = _categoryIcons[cat.name.toLowerCase()] ?? Icons.book;
              return _HomeCategoryChip(label: cat.name, icon: icon, onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CategoryBooksScreen(category: cat),
                ));
              });
            },
          ),
        ),
      ],
    );
  }
}

class _HomeCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeCategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppColors.iosSeparatorDark.withValues(alpha: 0.2)
                : AppColors.iosSeparatorLight.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
