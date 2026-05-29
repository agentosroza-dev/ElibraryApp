import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../config/api_config.dart';
import '../models/categories_model.dart';
import '../models/items_model.dart';
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
      lastPage: json['last_page'] != null ? '${json['last_page']}' : '0',
      totalPages: json['total_pages'] != null ? '${json['total_pages']}' : '0',
      percent: json['percent'] != null ? '${json['percent']}' : '0',
    );
  }
}

class HomeProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<RecommendedBook> _overallRecommended = [];
  List<BookItem> _popular = [];
  List<BookItem> _newBooks = [];
  List<ContinueReadingItem> _continueReading = [];
  List<Categories> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<RecommendedBook> get overallRecommended => _overallRecommended;
  List<BookItem> get popular => _popular;
  List<BookItem> get newBooks => _newBooks;
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
    _newBooks = [];
    _continueReading = [];
    _categories = [];

    final results = await Future.wait([
      _fetchSection(ApiConfig.recommendedOverall, (res) => _overallRecommended = _parseOverallRecommended(res)),
      _fetchSection(ApiConfig.homePopular, (res) => _popular = _parseBooks(res)),
      _fetchNewBooks(),
      _fetchSection(ApiConfig.homeContinueReading, (res) => _continueReading = _parseContinueReading(res)),
      _fetchSection(ApiConfig.categories, (res) => _categories = _parseCategories(res)),
    ]);

    final errors = results.whereType<String>().toList();
    if (errors.isNotEmpty) {
      _error = errors.join('\n');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<RecommendedBook> _parseOverallRecommended(Map<String, dynamic> response) {
    try {
      return OverallRecommendedBooks.fromJson(response).data;
    } catch (_) {
      return [];
    }
  }

  List<dynamic> _extractData(Map<String, dynamic> response) {
    final raw = response['data'];
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    return [];
  }

  List<BookItem> _parseBooks(Map<String, dynamic> response) {
    try {
      return _extractData(response)
          .map((e) => BookItem.fromJson(e is Map ? Map<String, dynamic>.from(e) : e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    return [];
  }

  List<Categories> _parseCategories(Map<String, dynamic> response) {
    try {
      return _extractData(response)
          .map((e) => Categories.fromJson(e is Map ? Map<String, dynamic>.from(e) : e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    return [];
  }

  List<ContinueReadingItem> _parseContinueReading(Map<String, dynamic> response) {
    try {
      return _extractData(response)
          .map((e) => ContinueReadingItem.fromJson(e is Map ? Map<String, dynamic>.from(e) : e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
    return [];
  }

  Future<String?> _fetchSection(String endpoint, void Function(Map<String, dynamic>) onSuccess) async {
    try {
      final res = await _client.get(endpoint, authenticate: true);
      onSuccess(res);
      return null;
    } catch (e) {
      return '$endpoint: $e';
    }
  }

  Future<String?> _fetchNewBooks() async {
    try {
      final res = await _client.get(ApiConfig.items, authenticate: true);
      final items = Items.fromJson(res);
      items.data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _newBooks = items.data.take(4).map((e) => BookItem(
        id: e.id,
        title: e.title,
        authorName: e.authorName,
        coverUrl: e.coverUrl ?? '',
        categoryName: e.categoryName,
      )).toList();
      return null;
    } catch (e) {
      return '${ApiConfig.items}: $e';
    }
  }
}
