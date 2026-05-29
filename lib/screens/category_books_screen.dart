import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../config/base_url.dart';
import '../config/theme.dart';
import '../models/categories_model.dart';
import '../providers/category_books_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/font_scale.dart';
import 'category_books_loading_state.dart';
import 'items_details_screen.dart';

String _coverUrl(String? url) {
  if (url == null || url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

class CategoryBooksScreen extends StatefulWidget {
  final Categories category;

  const CategoryBooksScreen({super.key, required this.category});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final ScrollController _scrollController = ScrollController();
  late CategoryBooksProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CategoryBooksProvider();
    _provider.fetchBooks(widget.category.id, refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _provider.fetchBooks(widget.category.id);
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
          style: TextStyle(fontSize: context.sp(17), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) => Column(
          children: [
            if (_provider.isFetchingMore && !_provider.loading)
              LinearProgressIndicator(
                backgroundColor: cs.primary.withValues(alpha: 0.12),
                color: cs.primary,
                minHeight: 3,
              ),
            Expanded(
              child: _buildBody(cs, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    if (_provider.loading) {
      return const CategoryBooksLoadingState();
    }
    if (_provider.error != null) {
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
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _provider.fetchBooks(widget.category.id, refresh: true),
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
    if (_provider.books.isEmpty) {
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
                fontSize: context.sp(15),
              ),
            ),
          ],
        ),
      );
    }
    final books = _provider.filteredBooks;
    final tags = _provider.allTags;
    return RefreshIndicator(
      onRefresh: () => _provider.fetchBooks(widget.category.id, refresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (tags.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: tags.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final selected = isAll
                        ? _provider.selectedTagId == null
                        : tags[index - 1].id == _provider.selectedTagId;
                    final label = isAll ? loc.translate('all') : tags[index - 1].name;
                    return GestureDetector(
                      onTap: () {
                        _provider.selectTag(
                          isAll ? null : tags[index - 1].id,
                          isAll ? null : tags[index - 1].name,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? cs.primary : (isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                            style: TextStyle(
                              fontSize: context.sp(13),
                              fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : cs.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                },
                childCount: books.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
