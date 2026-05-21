import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../utils/app_localizations.dart';
import 'home_widget/home_banner.dart';
import 'home_widget/home_book_section.dart';
import 'home_widget/home_categories.dart';
import 'home_widget/home_category_browse.dart';
import 'home_widget/home_continue_reading.dart';
import 'home_widget/home_header.dart';
import 'home_widget/home_loading_state.dart';
import 'home_widget/home_recommended_section.dart';

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
                const HomeHeader(),
                if (home.overallRecommended.isNotEmpty)
                  HomeBanner(books: home.overallRecommended),
                if (!home.isLoading) HomeCategories(cats: home.categories),
                if (home.isLoading)
                  const HomeLoadingState()
                else ...[
                  if (home.overallRecommended.isNotEmpty)
                    HomeRecommendedSection(
                      books: home.overallRecommended,
                      showGrid: _showRecommendedGrid,
                      onToggleGrid: () => setState(() => _showRecommendedGrid = !_showRecommendedGrid),
                    ),
                  const HomeCategoryBrowse(),
                  if (home.popular.isNotEmpty)
                    HomeBookSection(title: loc.translate('popular_books'), books: home.popular),
                  if (home.continueReading.isNotEmpty)
                    HomeContinueReading(books: home.continueReading),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
