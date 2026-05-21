import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/base_url.dart';
import '../../config/theme.dart';
import '../../providers/home_provider.dart';
import '../items_details_screen.dart';

String _coverUrl(String url) {
  if (url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

class HomeBookHorizontalList extends StatelessWidget {
  final List<BookItem> books;

  const HomeBookHorizontalList({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemsDetailsScreen.fromBookId(
                  id: book.id,
                  title: book.title,
                  author: book.authorName,
                  cover: _coverUrl(book.coverUrl),
                ),
              ),
            ),
            child: SizedBox(
              width: 130,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: _coverUrl(book.coverUrl),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Skeletonizer(
                          child: Container(
                            color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                          child: Icon(Icons.book, size: 48, color: AppColors.iosGray),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.authorName,
                            style: TextStyle(
                              color: AppColors.iosGray,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
