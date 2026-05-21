import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/api_config.dart';
import '../config/base_url.dart';
import '../config/theme.dart';
import '../models/items_model.dart';
import '../models/user_favorites.dart';
import '../services/api_client.dart';
import '../providers/user_favorites_provider.dart';
import '../utils/app_localizations.dart';
import 'read_book_screen.dart';

String _coverUrl(String url) {
  if (url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

class UserBookFavoritesScreen extends StatelessWidget {
  const UserBookFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final favProvider = context.watch<UserFavoritesProvider>();
    final favs = favProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('favorites'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: favProvider.loading
          ? const Center(
              child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 36),
            )
          : favProvider.error != null
              ? Center(
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
                )
              : favs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: AppColors.iosGray),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('no_favorites'),
                            style: TextStyle(fontSize: 15, color: AppColors.iosGray),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: favs.length,
                      itemBuilder: (context, index) {
                        final book = favs[index];
                        return _FavBookCard(book: book);
                      },
                    ),
    );
  }
}

class _FavBookCard extends StatelessWidget {
  final Favorite book;
  const _FavBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _openBook(context, book),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: _coverUrl(book.image),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Skeletonizer(
                  child: Container(color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6),
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: TextStyle(color: AppColors.iosGray, fontSize: 11),
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

  Future<void> _openBook(BuildContext context, Favorite book) async {
    final bookId = int.tryParse(book.id);
    if (bookId == null) return;

    final client = ApiClient();
    try {
      final response = await client.get(ApiConfig.item(bookId), authenticate: true);
      final itemJson = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      final item = ItemData.fromJson(itemJson);
      final fileUrl = item.fileUrl;
      if (fileUrl == null || fileUrl.isEmpty) {
        if (context.mounted) {
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
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadBookScreen(url: url, title: item.title),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
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
}
