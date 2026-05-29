import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/api_config.dart';
import '../config/base_url.dart';
import '../config/theme.dart';
import '../models/items_model.dart';
import '../providers/user_favorites_provider.dart';
import '../services/api_client.dart';
import '../utils/app_localizations.dart';
import '../utils/font_scale.dart';
import 'home_widget/recommended_books_section.dart';
import 'read_book_screen.dart';
import 'user_book_favorites_screen.dart';

String _coverUrl(String? url) {
  if (url == null || url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

class ItemsDetailsScreen extends StatefulWidget {
  final ItemData? item;
  final String? bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCover;

  const ItemsDetailsScreen({super.key, required this.item})
      : bookId = null,
        bookTitle = null,
        bookAuthor = null,
        bookCover = null;

  const ItemsDetailsScreen.fromBookId({
    super.key,
    required String id,
    String? title,
    String? author,
    String? cover,
  }) : item = null,
       bookId = id,
       bookTitle = title,
       bookAuthor = author,
       bookCover = cover;

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  final ApiClient _client = ApiClient();
  bool _isFavoriting = false;
  bool _isFavorite = false;
  ItemData? _fetchedItem;
  bool _isFetching = false;

  ItemData? get _item => widget.item ?? _fetchedItem;

  @override
  void initState() {
    super.initState();
    if (widget.item == null && widget.bookId != null) {
      _fetchItem();
    }
  }

  Future<void> _fetchItem() async {
    setState(() => _isFetching = true);
    try {
      final id = int.tryParse(widget.bookId!);
      if (id == null) return;
      final response = await _client.get(
        ApiConfig.item(id),
        authenticate: true,
      );
      if (mounted) {
        final itemJson = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        _fetchedItem = ItemData.fromJson(itemJson);
        _checkFavorite(id);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load book details'),
            backgroundColor: AppColors.iosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _checkFavorite(int bookId) async {
    try {
      final response = await _client.get(
        ApiConfig.favoriteCheck(bookId),
        authenticate: true,
      );
      if (mounted) {
        final isFav = response['is_favorite'] == true || response['data']?['is_favorite'] == true;
        setState(() => _isFavorite = isFav);
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (_item == null) return;
    setState(() => _isFavoriting = true);
    try {
      final bookId = int.tryParse(_item!.id);
      if (bookId == null) return;
      if (_isFavorite) {
        await _client.delete(
          ApiConfig.favorite(bookId),
          authenticate: true,
        );
      } else {
        await _client.post(
          ApiConfig.favorite(bookId),
          authenticate: true,
        );
      }
      if (mounted) {
        final newState = !_isFavorite;
        setState(() => _isFavorite = newState);
        context.read<UserFavoritesProvider>().fetchFavorites(refresh: true);
        final bookName = _item!.title;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newState ? Icons.favorite : Icons.favorite_border,
                  color: newState ? AppColors.iosRed : Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        newState ? 'Added to favorites' : 'Removed from favorites',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
            action: newState
                ? SnackBarAction(
                    label: 'Go',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserBookFavoritesScreen(),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to toggle favorite'),
            backgroundColor: AppColors.iosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isFavoriting = false);
    }
  }

  void _readBook() {
    if (_item == null) return;
    final fileUrl = _item!.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No file available for this book'),
          backgroundColor: AppColors.iosGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final title = _item!.title;
    final url = '${BaseURL.base}/library/details/view/${_item!.id}/pdf-progress?file=$fileUrl&title=${Uri.encodeComponent(title)}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadBookScreen(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = _item;
    final title = item?.title ?? widget.bookTitle ?? '';
    final author = item?.authorName ?? widget.bookAuthor ?? '';
    final cover = _coverUrl(item?.coverUrl ?? widget.bookCover);
    final category = item?.categoryName ?? '';
    final description = item?.description;
    final publishYear = item?.publishYear;
    final language = item?.language;
    final tags = item?.tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: context.sp(17), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isFetching
          ? const Center(child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 40))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: cover,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Skeletonizer(
                        child: Container(
                          height: 280,
                          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 280,
                        color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                        child: Icon(Icons.book, size: 80, color: AppColors.iosGray),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: context.sp(24),
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (author.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                      child: Text(
                        author,
                        style: TextStyle(
                          fontSize: context.sp(16),
                          color: AppColors.iosGray,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (publishYear != null && publishYear.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.tertiary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              publishYear,
                              style: TextStyle(
                                color: cs.tertiary,
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (language != null && language.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              language,
                              style: TextStyle(
                                color: cs.secondary,
                                fontSize: context.sp(12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (tags != null && tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('tags'),
                            style: TextStyle(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.iosGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.iosGrayDark3 : AppColors.iosGray4,
                                ),
                              ),
                              child: Text(
                                tag.name,
                                style: TextStyle(
                                  fontSize: context.sp(12),
                                  color: cs.onSurface,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  if (description != null && description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: context.sp(15),
                          color: isDark ? AppColors.iosGrayDark : AppColors.iosGray2,
                          height: 1.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _readBook,
                              icon: const Icon(Icons.menu_book, size: 20),
                              label: Text(
                                loc.translate('read_now'),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _isFavoriting ? null : _toggleFavorite,
                              icon: _isFavoriting
                                  ? const SpinKitFadingCircle(size: 18, color: Colors.white)
                                  : Icon(
                                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 20,
                                    ),
                              label: Text(
                                loc.translate('favorites'),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isFavorite ? AppColors.iosRed : cs.primary,
                                side: BorderSide(
                                  color: (_isFavorite ? AppColors.iosRed : cs.primary).withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const RecommendedBooksSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
