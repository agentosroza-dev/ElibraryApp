import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../config/theme.dart';
import '../models/categories_model.dart';
import '../models/overall_recommended_books.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../utils/app_localizations.dart';
import 'category_books_screen.dart';
import 'items_details_screen.dart';

const Map<String, IconData> _categoryIcons = {
  'fiction': Icons.auto_stories,
  'science': Icons.science,
  'history': Icons.history_edu,
  'technology': Icons.computer,
  'art': Icons.palette,
  'philosophy': Icons.psychology,
  'mathematics': Icons.calculate,
  'education': Icons.school,
  'literature': Icons.menu_book,
  'programming': Icons.code,
  'business': Icons.business_center,
  'self-help': Icons.self_improvement,
  'health': Icons.favorite,
  'travel': Icons.flight,
  'religion': Icons.church,
  'comics': Icons.chat_bubble,
  'children': Icons.toys,
  'reference': Icons.library_books,
  'nature': Icons.forest,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRecommendedGrid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        return RefreshIndicator(
          onRefresh: home.fetchAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                if (home.overallRecommended.isNotEmpty)
                  _buildBanner(context, home.overallRecommended),
                if (!home.isLoading) _buildCategories(context, home.categories),
                if (home.isLoading)
                  _buildLoadingState()
                else ...[
                  if (home.overallRecommended.isNotEmpty)
                    _buildRecommendedSection(context, home.overallRecommended),
                  if (home.popular.isNotEmpty)
                    _buildBookSection(context, loc.translate('popular_books'), home.popular),
                  if (home.continueReading.isNotEmpty)
                    _buildContinueReading(context, home.continueReading),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(80),
      child: Center(child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 40)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${loc.translate('hello')}, ${auth.userName.isNotEmpty ? auth.userName : loc.translate('reader')}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.translate('what_to_read'),
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.iosGray,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.iosGray5, width: 2),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
              backgroundImage: auth.userPhoto != null
                  ? CachedNetworkImageProvider(auth.userPhoto!)
                  : null,
              child: auth.userPhoto == null
                  ? Icon(Icons.person, color: AppColors.iosGray, size: 24)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context, List<RecommendedBook> books) {
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
              return Container(
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              book.authorName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.iosBlue,
                                    AppColors.iosDarkBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text(
                                loc.translate('read_now'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
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
                                imageUrl: book.coverUrl,
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
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<Categories> cats) {
    if (cats.isEmpty) return const SizedBox.shrink();
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('categories'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
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
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cats.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(context, loc.translate('all'), Icons.explore, () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CategoryBooksScreen(category: Categories(id: '0', name: 'All', slug: 'all', description: '', isActive: 'true', createdAt: '', updatedAt: '')),
                  ));
                });
              }
              final cat = cats[index - 1];
              final icon = _categoryIcons[cat.name.toLowerCase()] ?? Icons.book;
              return _buildCategoryChip(context, cat.name, icon, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CategoryBooksScreen(category: cat),
                ));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppColors.iosSeparatorDark.withValues(alpha: 0.2)
                : AppColors.iosSeparatorLight.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context, List<RecommendedBook> books) {
    final loc = AppLocalizations.of(context);
    final items = books.map((b) => BookItem(
      id: b.id, title: b.title, authorName: b.authorName,
      coverUrl: (b.coverUrl.isNotEmpty && b.coverUrl != 'null') ? b.coverUrl : null,
      categoryName: b.categoryName,
    )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('recommended'),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_showRecommendedGrid ? Icons.grid_on : Icons.grid_view, size: 20),
                    onPressed: () => setState(() => _showRecommendedGrid = !_showRecommendedGrid),
                    tooltip: _showRecommendedGrid ? loc.translate('list_view') : loc.translate('grid_view'),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showRecommendedGrid) _buildBookGrid(items) else _buildBookHorizontalList(items),
      ],
    );
  }

  Widget _buildBookSection(BuildContext context, String title, List<BookItem> books) {
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
        _buildBookHorizontalList(books),
      ],
    );
  }

  Widget _buildBookHorizontalList(List<BookItem> books) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 210,
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
                  cover: book.coverUrl,
                ),
              ),
            ),
            child: SizedBox(
              width: 130,
              child: Column(
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
                        child: CachedNetworkImage(
                          imageUrl: book.coverUrl ?? '',
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
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookGrid(List<BookItem> books) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16,
        ),
        itemCount: books.length,
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
                  cover: book.coverUrl,
                ),
              ),
            ),
            child: Column(
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
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl ?? '',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                          child: Icon(Icons.book, size: 48, color: AppColors.iosGray),
                        ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueReading(BuildContext context, List<ContinueReadingItem> books) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, size: 22, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    loc.translate('continue_reading'),
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
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              return SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
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
                              child: CachedNetworkImage(
                                imageUrl: book.coverUrl ?? '',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                                  child: Icon(Icons.book, size: 48, color: AppColors.iosGray),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              child: LinearProgressIndicator(
                                value: double.parse(book.percent) / 100,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                color: cs.primary,
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
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
                      '${double.parse(book.percent).toStringAsFixed(0)}${loc.translate('percent_complete')}',
                      style: TextStyle(
                        color: AppColors.iosGray,
                        fontSize: 12,
                      ),
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
}
