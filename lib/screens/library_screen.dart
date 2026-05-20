import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/theme.dart';
import '../utils/app_localizations.dart';

final List<Map<String, String>> _favoriteBooks = [
  {
    'title': '1984',
    'author': 'George Orwell',
    'image': 'https://covers.openlibrary.org/b/id/12648637-L.jpg',
  },
  {
    'title': 'The Great Gatsby',
    'author': 'F. Scott Fitzgerald',
    'image': 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
  },
];

final List<Map<String, dynamic>> _recentlyRead = [
  {
    'title': 'Brave New World',
    'author': 'Aldous Huxley',
    'image': 'https://covers.openlibrary.org/b/id/12645808-L.jpg',
    'progress': 0.45,
  },
  {
    'title': 'The Catcher in the Rye',
    'author': 'J.D. Salinger',
    'image': 'https://covers.openlibrary.org/b/id/12652713-L.jpg',
    'progress': 0.72,
  },
];

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, cs),
          if (_favoriteBooks.isNotEmpty) _buildFavorites(context, cs, isDark),
          if (_recentlyRead.isNotEmpty) _buildRecentlyRead(context, cs, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Text(
        loc.translate('library'),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildFavorites(BuildContext context, ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: AppColors.iosRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    loc.translate('favorites'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                loc.translate('see_all'),
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _favoriteBooks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = _favoriteBooks[index];
              return SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: book['image']!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Skeletonizer(
                            child: Container(
                              color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                            child: Icon(Icons.book, size: 40, color: AppColors.iosGray),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyRead(BuildContext context, ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Icon(Icons.history, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                loc.translate('recently_read'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _recentlyRead.map((book) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: book['image'] as String,
                          width: 48,
                          height: 64,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Skeletonizer(
                            child: Container(
                              width: 48,
                              height: 64,
                              color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            width: 48,
                            height: 64,
                            color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                            child: Icon(Icons.book, color: AppColors.iosGray),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              book['author'] as String,
                              style: TextStyle(
                                color: AppColors.iosGray,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: book['progress'] as double,
                                minHeight: 5,
                                backgroundColor: isDark
                                    ? AppColors.iosGrayDark4
                                    : AppColors.iosGray5,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${((book['progress'] as double) * 100).toInt()}%',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
