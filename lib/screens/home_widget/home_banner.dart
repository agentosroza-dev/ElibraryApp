import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../config/base_url.dart';
import '../../config/theme.dart';
import '../../models/overall_recommended_books.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';
import '../items_details_screen.dart';
import '../read_book_screen.dart';

String _coverUrl(String url) {
  if (url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

String _readBookUrl(RecommendedBook book) {
  return '${BaseURL.base}/library/details/view/${book.id}/pdf-progress'
      '?file=${book.fileUrl}'
      '&title=${Uri.encodeComponent(book.title)}';
}

class HomeBanner extends StatelessWidget {
  final List<RecommendedBook> books;

  const HomeBanner({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
        ),
        items: books.map((book) {
          return Builder(
            builder: (context) {
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
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.iosDarkBlue.withValues(alpha: 0.9),
                        const Color(0xFF1A1A2E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.iosDarkBlue.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                book.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w700,
                              ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book.authorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: context.sp(11),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () {
                                  final url = _readBookUrl(book);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReadBookScreen(url: url, title: book.title),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.iosBlue,
                                        AppColors.iosDarkBlue,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                     overflow: TextOverflow.ellipsis,
                                    loc.translate('read_now'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(11),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          child: book.coverUrl.isNotEmpty && book.coverUrl != 'null'
                              ? CachedNetworkImage(
                                  imageUrl: _coverUrl(book.coverUrl),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(color: Colors.white.withValues(alpha: 0.08)),
                                  errorWidget: (_, _, _) => Container(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    child: const Icon(Icons.book, color: Colors.white38),
                                  ),
                                )
                              : Container(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  child: const Icon(Icons.book, color: Colors.white38),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
