import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../models/items_model.dart';
import '../services/api_client.dart';
import '../utils/app_localizations.dart';
import 'items_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final ApiClient _client = ApiClient();
  final FocusNode _searchFocus = FocusNode();
  List<ItemData> _allResults = [];
  String _searchQuery = '';

  List<ItemData> get _filteredResults {
    if (_searchQuery.trim().isEmpty) return _allResults;
    final q = _searchQuery.trim().toLowerCase();
    return _allResults.where((e) => e.title.toLowerCase().contains(q)).toList();
  }

  bool _isLoading = true;
  String? _error;
  bool _showCancel = false;

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAllItems() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await _client.get(ApiConfig.items, authenticate: true);
      final items = Items.fromJson(response);
      if (mounted) setState(() => _allResults = items.data);
    } catch (e) {
      if (mounted) setState(() { _allResults = []; _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() { _searchQuery = ''; _showCancel = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSearchBar(cs, isDark),
        Expanded(
          child: _buildBody(cs, isDark, _filteredResults),
        ),
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
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosBackgroundDark : AppColors.iosCardLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
                : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onTap: () => setState(() => _showCancel = true),
                style: TextStyle(
                  fontSize: 17,
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: loc.translate('search'),
                  hintStyle: TextStyle(
                    color: AppColors.iosGray,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.iosGray,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
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
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          if (_showCancel)
            GestureDetector(
              onTap: () {
                _searchFocus.unfocus();
                _clearSearch();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  loc.translate('cancel'),
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, bool isDark, List<ItemData> results) {
    if (_isLoading) {
      return Center(
        child: SpinKitFadingCircle(
          color: cs.primary,
          size: 36,
        ),
      );
    }

    if (results.isEmpty) {
      return _buildEmptyState(cs);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final isPdf = item.fileUrl != null && item.fileUrl!.isNotEmpty;
        return _buildResultItem(item, isPdf, cs, isDark);
      },
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
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
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _error != null ? Icons.error_outline : Icons.search_off,
                size: 36,
                color: _error != null
                    ? cs.error.withValues(alpha: 0.7)
                    : AppColors.iosGray,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _error ?? loc.translate('no_results'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error != null
                  ? loc.translate('something_wrong')
                  : loc.translate('try_different'),
              style: TextStyle(
                fontSize: 15,
                color: AppColors.iosGray,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadAllItems,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                ),
                child: Text(loc.translate('retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(ItemData item, bool isPdf, ColorScheme cs, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemsDetailsScreen(item: item)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      item.coverUrl != null && item.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.coverUrl!,
                              width: 52,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Skeletonizer(
                                child: Container(
                                  width: 52,
                                  height: 72,
                                  color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                width: 52,
                                height: 72,
                                color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                                child: Icon(Icons.book, color: AppColors.iosGray, size: 24),
                              ),
                            )
                          : Container(
                              width: 52,
                              height: 72,
                              color: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                              child: Icon(Icons.book, color: AppColors.iosGray, size: 24),
                            ),
                      if (isPdf)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.iosRed.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.picture_as_pdf, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: cs.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPdf)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.iosRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                loc.translate('pdf_badge'),
                                style: TextStyle(
                                  color: AppColors.iosRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.authorName,
                        style: TextStyle(
                          color: AppColors.iosGray,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.description!,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.iosGrayDark
                                : AppColors.iosGray2,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.iosGray3, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
