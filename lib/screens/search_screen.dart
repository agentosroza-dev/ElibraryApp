import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/base_url.dart';
import '../config/theme.dart';
import '../logics/search_logic.dart';
import '../models/trending_search.dart' as trending;
import '../models/suggested_search.dart' as suggested;
import '../utils/app_localizations.dart';
import '../utils/font_scale.dart';
import 'items_details_screen.dart';

String _coverUrl(String url) {
  if (url.isEmpty || url == 'null') return '';
  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) return 'https://${url.substring(7)}';
  if (url.startsWith('/')) return '${BaseURL.base}$url';
  return '${BaseURL.base}/storage/$url';
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final SearchLogic _logic = SearchLogic();
  bool _isLoading = true;
  String? _error;
  List<trending.Datum> _trending = [];
  List<suggested.Datum> _suggested = [];
  List<suggested.Datum> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _logic.fetchInitialData();
      if (!mounted) return;
      setState(() {
        _trending = data.trending;
        _suggested = data.suggested;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _updateSearch(String v) {
    final q = v.trim().toLowerCase();
    setState(() {
      _filteredSuggestions = q.isNotEmpty
          ? _suggested.where((e) => e.title.toLowerCase().contains(q)).toList()
          : [];
    });
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _error = null;
      _filteredSuggestions = [];
    });
  }

  void _onTrendingTagTapped(String tagName) {
    _controller.text = tagName;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: tagName.length),
    );
    _updateSearch(tagName);
  }

  Future<void> _openSuggestion(suggested.Datum item) async {
    try {
      final itemData = await _logic.fetchItemDetail(item.id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemsDetailsScreen(item: itemData),
        ),
      );
    } catch (_) {
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSearchBar(cs, isDark),
        Expanded(child: _buildBody(cs, isDark)),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: TextStyle(
          fontSize: context.sp(17),
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: loc.translate('search'),
          hintStyle: TextStyle(
            color: AppColors.iosGray,
            fontSize: context.sp(17),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.iosGray,
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.iosGrayDark3
                          : AppColors.iosGray4,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: cs.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        onChanged: (v) {
          _updateSearch(v);
        },
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, bool isDark) {
    if (_isLoading) {
      return Center(
        child: SpinKitFadingCircle(color: cs.primary, size: 36),
      );
    }

    if (_error != null && _trending.isEmpty && _suggested.isEmpty) {
      return _buildErrorState(cs);
    }

    if (_controller.text.isNotEmpty) {
      return _buildResultsList(cs, isDark);
    }

    return _buildExploreContent(cs, isDark);
  }

  Widget _buildErrorState(ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 36,
                color: cs.error.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.translate('something_wrong'),
              style: TextStyle(
                fontSize: context.sp(20),
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? loc.translate('try_different'),
              style: TextStyle(
                fontSize: context.sp(15),
                color: AppColors.iosGray,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchInitialData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 44),
              ),
              child: Text(loc.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreContent(ColorScheme cs, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Trending'),
          _buildTrendingRow(cs, isDark),
          if (_suggested.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Suggested for You'),
            _buildSuggestedGrid(cs, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.iosGray,
          fontSize: context.sp(13),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTrendingRow(ColorScheme cs, bool isDark) {
    if (_trending.isEmpty) {
      return const SizedBox(height: 44);
    }
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _trending.length,
        itemBuilder: (context, index) {
          final item = _trending[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onTrendingTagTapped(item.name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.iosSeparatorDark.withValues(alpha: 0.2)
                        : AppColors.iosSeparatorLight.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: AppColors.iosOrange,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if ((int.tryParse(item.trendingScore) ?? 0) > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.trendingScore,
                          style: TextStyle(
                            fontSize: context.sp(11),
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestedGrid(ColorScheme cs, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _suggested.length,
        itemBuilder: (context, index) {
          final item = _suggested[index];
          return _buildSuggestedCard(item, cs, isDark);
        },
      ),
    );
  }

  Widget _buildSuggestedCard(suggested.Datum item, ColorScheme cs, bool isDark) {
    return GestureDetector(
      onTap: () => _openSuggestion(item),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: _coverUrl(item.coverUrl),
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
                  child: const Icon(Icons.book, size: 48, color: AppColors.iosGray),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: context.sp(13),
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.author.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.iosGray,
                      fontSize: context.sp(11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(ColorScheme cs, bool isDark) {
    if (_filteredSuggestions.isEmpty) {
      return SizedBox.expand(
        child: _buildEmptyState(cs),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredSuggestions.length,
      itemBuilder: (context, index) {
        final item = _filteredSuggestions[index];
        return _buildResultItem(item, cs, isDark);
      },
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.search_off,
                size: 36,
                color: AppColors.iosGray,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.translate('no_results'),
              style: TextStyle(
                fontSize: context.sp(20),
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('try_different'),
              style: TextStyle(
                fontSize: context.sp(15),
                color: AppColors.iosGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(suggested.Datum item, ColorScheme cs, bool isDark) {
    final isPdf = item.fileUrl.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openSuggestion(item),
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
                        child: const Icon(Icons.book, color: AppColors.iosGray, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: context.sp(15),
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 13, color: AppColors.iosGray),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.author.name,
                                style: TextStyle(
                                  color: AppColors.iosGray,
                                  fontSize: context.sp(13),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (isPdf)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.iosRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PDF',
                                  style: TextStyle(
                                    fontSize: context.sp(10),
                                    color: AppColors.iosRed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            if (isPdf && item.category.name.isNotEmpty)
                              const SizedBox(width: 6),
                            if (item.category.name.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.category.name,
                                  style: TextStyle(
                                    fontSize: context.sp(10),
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: AppColors.iosGray3, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
