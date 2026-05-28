import 'package:flutter/material.dart';

import '../../models/overall_recommended_books.dart';
import '../../providers/home_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';
import 'home_book_grid.dart';
import 'home_book_horizontal_list.dart';

class HomeRecommendedSection extends StatelessWidget {
  final List<RecommendedBook> books;
  final bool showGrid;
  final VoidCallback onToggleGrid;

  const HomeRecommendedSection({
    super.key,
    required this.books,
    required this.showGrid,
    required this.onToggleGrid,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final items = books.map((b) => BookItem(
      id: b.id, title: b.title, authorName: b.authorName,
      coverUrl: (b.coverUrl.isNotEmpty && b.coverUrl != 'null') ? b.coverUrl : '',
      categoryName: b.categoryName,
    )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('recommended'),
              style: TextStyle(
                fontSize: context.sp(22),
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(showGrid ? Icons.grid_on : Icons.grid_view, size: 20),
                    onPressed: onToggleGrid,
                    tooltip: showGrid ? loc.translate('list_view') : loc.translate('grid_view'),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showGrid) HomeBookGrid(books: items) else HomeBookHorizontalList(books: items),
      ],
    );
  }
}
