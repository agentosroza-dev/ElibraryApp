import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/base_url.dart';
import '../../config/theme.dart';
import '../../models/overall_recommended_books.dart';
import '../../providers/recommended_provider.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';
import '../items_details_screen.dart';

String _coverUrl(String url) {
  if (url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

class RecommendedBooksSection extends StatefulWidget {
  const RecommendedBooksSection({super.key});

  @override
  State<RecommendedBooksSection> createState() => _RecommendedBooksSectionState();
}

class _RecommendedBooksSectionState extends State<RecommendedBooksSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecommendedProvider>();
      if (provider.books.isEmpty && !provider.isLoading) {
        provider.fetchRecommended();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendedProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.books.isEmpty) {
          return _buildShimmer(context);
        }
        if (provider.books.isEmpty) return const SizedBox.shrink();
        return _buildSection(context, provider.books);
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, _) => Skeletonizer(
              child: SizedBox(
                width: 150,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Loading Title'),
                            SizedBox(height: 2),
                            Text('Author Name'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, List<RecommendedBook> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(
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
                child: _buildBookCard(context, book),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
      child: Text(
        loc.translate('recommended'),
        style: TextStyle(
          fontSize: context.sp(22),
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, RecommendedBook book) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 150,
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
                      fontSize: context.sp(13),
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
                      fontSize: context.sp(11),
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
    );
  }
}
