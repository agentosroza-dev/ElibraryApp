import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/categories_model.dart';
import '../models/items_model.dart';
import '../services/api_client.dart';
import '../utils/app_localizations.dart';

class CategoryBooksScreen extends StatefulWidget {
  final Categories category;

  const CategoryBooksScreen({super.key, required this.category});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final ApiClient _client = ApiClient();
  List<ItemData> _books = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final url = widget.category.id == '0'
          ? ApiConfig.items
          : '${ApiConfig.items}?category_id=${widget.category.id}';
      final response = await _client.get(url, authenticate: true);
      final items = Items.fromJson(response);
      if (mounted) setState(() => _books = items.data);
    } catch (e) {
      if (mounted) setState(() { _books = []; _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(cs, isDark),
    );
  }

  Widget _buildBody(ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(
        child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 36),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(Icons.error_outline, size: 32, color: cs.error.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              Text(
                loc.translate('failed_load_books'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchBooks,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                child: Text(loc.translate('retry')),
              ),
            ],
          ),
        ),
      );
    }
    if (_books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(Icons.menu_book, size: 32, color: AppColors.iosGray),
            ),
            const SizedBox(height: 16),
            Text(
              loc.translate('no_books_category'),
              style: TextStyle(
                color: AppColors.iosGray,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchBooks,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: book.coverUrl!,
                            width: double.infinity,
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
                          )
                        : Container(
                            color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                            child: Icon(Icons.book, size: 48, color: AppColors.iosGray),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                book.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
