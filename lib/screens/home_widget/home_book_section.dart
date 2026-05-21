import 'package:flutter/material.dart';

import '../../providers/home_provider.dart';
import '../../utils/app_localizations.dart';
import 'home_book_horizontal_list.dart';

class HomeBookSection extends StatelessWidget {
  final String title;
  final List<BookItem> books;

  const HomeBookSection({super.key, required this.title, required this.books});

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
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                loc.translate('see_all'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        HomeBookHorizontalList(books: books),
      ],
    );
  }
}
