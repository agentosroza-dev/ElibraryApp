import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';
import '../models/categories_model.dart';
import '../models/overall_recommended_books.dart';

class BookItem {
  String id;
  String title;
  String authorName;
  String coverUrl;
  String categoryName;

  BookItem({
    required this.id,
    required this.title,
    required this.authorName,
    this.coverUrl = '',
    this.categoryName = '',
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      id: '${json['id']}',
      title: '${json['title']}',
      authorName: '${json['author_name']}',
      coverUrl: '${json['cover_url']}',
      categoryName: '${json['category_name']}',
    );
  }
}

class ContinueReadingItem {
  String id;
  String itemId;
  String title;
  String authorName;
  String coverUrl;
  String lastPage;
  String totalPages;
  String percent;

  ContinueReadingItem({
    required this.id,
    required this.itemId,
    required this.title,
    required this.authorName,
    this.coverUrl = '',
    required this.lastPage,
    required this.totalPages,
    required this.percent,
  });

  factory ContinueReadingItem.fromJson(Map<String, dynamic> json) {
    return ContinueReadingItem(
      id: '${json['id']}',
      itemId: '${json['item_id']}',
      title: '${json['title']}',
      authorName: '${json['author_name']}',
      coverUrl: '${json['cover_url']}',
      lastPage: '${json['last_page']}',
      totalPages: '${json['total_pages']}',
      percent: '${json['percent']}',
    );
  }
}

class HomeProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<RecommendedBook> _overallRecommended = [];
  List<BookItem> _popular = [];
  List<ContinueReadingItem> _continueReading = [];
  List<Categories> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<RecommendedBook> get overallRecommended => _overallRecommended;
  List<BookItem> get popular => _popular;
  List<ContinueReadingItem> get continueReading => _continueReading;
  List<Categories> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _overallRecommended = [];
    _popular = [];
    _continueReading = [];
    _categories = [];

    final results = await Future.wait([
      _safeGet(ApiConfig.recommendedOverall).then(_parseOverallRecommended).catchError((_) => <RecommendedBook>[]),
      _safeGet(ApiConfig.homePopular).then(_parseBooks).catchError((_) => <BookItem>[]),
      _safeGet(ApiConfig.homeContinueReading).then(_parseContinueReading).catchError((_) => <ContinueReadingItem>[]),
      _safeGet(ApiConfig.categories).then(_parseCategories).catchError((_) => <Categories>[]),
    ]);

    _overallRecommended = results[0] as List<RecommendedBook>;
    _popular = results[1] as List<BookItem>;
    _continueReading = results[2] as List<ContinueReadingItem>;
    _categories = results[3] as List<Categories>;

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> _safeGet(String endpoint) async {
    try {
      return await _client.get(endpoint, authenticate: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  List<RecommendedBook> _parseOverallRecommended(Map<String, dynamic> response) {
    try {
      return OverallRecommendedBooks.fromJson(response).data;
    } catch (_) {
      return [];
    }
  }

  List<BookItem> _parseBooks(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data.map((e) => BookItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  List<Categories> _parseCategories(Map<String, dynamic> response) {
    try {
      final data = response['data'];
      if (data is List) {
        return data.map((e) => Categories.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  List<ContinueReadingItem> _parseContinueReading(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => ContinueReadingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
