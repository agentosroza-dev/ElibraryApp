import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/api_config.dart';
import '../config/base_url.dart';
import '../config/theme.dart';
import '../models/items_model.dart';
import '../models/pdf_progress_model.dart';
import '../services/api_client.dart';
import '../utils/app_localizations.dart';
import '../models/user_favorites.dart';
import '../providers/pdf_progress_provider.dart';
import '../providers/user_favorites_provider.dart';
import 'read_book_screen.dart';
import 'user_book_favorites_screen.dart';

String _coverUrl(String url) {
  if (url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}



class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiClient _client = ApiClient();

  @override
  void initState() {
    super.initState();
    final favProvider = context.read<UserFavoritesProvider>();
    if (favProvider.favorites.isEmpty) {
      favProvider.fetchFavorites(refresh: true);
    }
    context.read<PdfProgressProvider>().fetchProgressList(refresh: true);
  }

  Future<void> _openFavoriteBook(Favorite book) async {
    final bookId = int.tryParse(book.id);
    if (bookId == null) return;

    try {
      final response = await _client.get(ApiConfig.item(bookId), authenticate: true);
      final itemJson = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      final item = ItemData.fromJson(itemJson);
      final fileUrl = item.fileUrl;
      if (fileUrl == null || fileUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No file available for this book'),
              backgroundColor: AppColors.iosGray,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return;
      }
      final url = '${BaseURL.base}/library/details/view/${item.id}/pdf-progress'
          '?file=$fileUrl'
          '&title=${Uri.encodeComponent(item.title)}';
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadBookScreen(url: url, title: item.title),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load book'),
            backgroundColor: AppColors.iosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _openRecentRead(Datum item) {
    final fileUrl = item.fileUrl;
    if (fileUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No file available for this book'),
            backgroundColor: AppColors.iosGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }
    final url = '${BaseURL.base}/library/details/view/${item.itemId}/pdf-progress'
        '?file=$fileUrl'
        '&title=${Uri.encodeComponent(item.title)}';
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReadBookScreen(url: url, title: item.title),
        ),
      ).then((_) {
        if (mounted) {
          context.read<PdfProgressProvider>().fetchProgressList(refresh: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favProvider = context.watch<UserFavoritesProvider>();
    final progressProvider = context.watch<PdfProgressProvider>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, cs),
          _buildFavoritesSection(context, cs, isDark, favProvider),
          _buildRecentlyReadSection(context, cs, isDark, progressProvider),
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

  Widget _buildFavoritesSection(BuildContext context, ColorScheme cs, bool isDark, UserFavoritesProvider favProvider) {
    if (favProvider.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 36)),
      );
    }
    if (favProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: cs.error.withValues(alpha: 0.7)),
              const SizedBox(height: 12),
              Text(
                favProvider.error!,
                style: TextStyle(color: cs.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => favProvider.fetchFavorites(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (favProvider.favorites.isEmpty) return const SizedBox.shrink();
    return _buildFavorites(context, cs, isDark, favProvider);
  }

  Widget _buildFavorites(BuildContext context, ColorScheme cs, bool isDark, UserFavoritesProvider favProvider) {
    final loc = AppLocalizations.of(context);
    final favs = favProvider.favorites;
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
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserBookFavoritesScreen()),
                ),
                child: Text(
                  loc.translate('see_all'),
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
            itemCount: favs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = favs[index];
              return GestureDetector(
                onTap: () => _openFavoriteBook(book),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: _coverUrl(book.image),
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
                        book.title,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyReadSection(
      BuildContext context, ColorScheme cs, bool isDark, PdfProgressProvider provider) {
    final loc = AppLocalizations.of(context);

    if (provider.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 36)),
      );
    }

    if (provider.progressList.isEmpty) return const SizedBox.shrink();

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
            children: provider.progressList.map((item) {
              final progress = (double.tryParse(item.percent) ?? 0) / 100;
              return GestureDetector(
                onTap: () => _openRecentRead(item),
                child: Container(
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
                          imageUrl: _coverUrl(item.coverUrl),
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
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.authorName,
                              style: TextStyle(
                                color: AppColors.iosGray,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
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
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
