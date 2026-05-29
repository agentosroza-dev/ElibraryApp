import 'package:flutter/material.dart';

import '../../providers/home_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';
import 'home_book_grid.dart';
import 'home_book_horizontal_list.dart';

class HomeNewBookSection extends StatelessWidget {
  final List<BookItem> books;
  final bool showGrid;
  final VoidCallback onToggleGrid;

  const HomeNewBookSection({
    super.key,
    required this.books,
    required this.showGrid,
    required this.onToggleGrid,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('new_books'),
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
        if (showGrid) HomeBookGrid(books: books) else HomeBookHorizontalList(books: books),
      ],
    );
  }
}
