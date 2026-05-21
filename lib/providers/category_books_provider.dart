import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/items_model.dart';
import '../services/api_client.dart';

class CategoryBooksProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<ItemData> _books = [];
  List<ItemData> get books => _books;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  String? _nextPageUrl;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  String? _selectedTagId;
  String? get selectedTagId => _selectedTagId;
  String? _selectedTagName;
  String? get selectedTagName => _selectedTagName;

  List<ItemData> get filteredBooks {
    if (_selectedTagId == null) return _books;
    return _books.where((b) => b.tags.any((t) => t.id == _selectedTagId)).toList();
  }

  List<Tag> get allTags {
    final map = <String, Tag>{};
    for (final book in _books) {
      for (final tag in book.tags) {
        map[tag.id] = tag;
      }
    }
    return map.values.toList();
  }

  void selectTag(String? tagId, String? tagName) {
    _selectedTagId = tagId;
    _selectedTagName = tagName;
    notifyListeners();
  }

  Future<void> fetchBooks(String categoryId, {bool refresh = false}) async {
    if (!refresh && _nextPageUrl == null && _books.isNotEmpty) return;
    if (_isFetchingMore) return;

    _isFetchingMore = true;
    if (refresh) {
      _loading = true;
      _error = null;
      _selectedTagId = null;
      _selectedTagName = null;
    }
    notifyListeners();

    try {
      final url = refresh || _nextPageUrl == null
          ? (categoryId == '0'
              ? ApiConfig.items
              : '${ApiConfig.items}?category_id=$categoryId')
          : _nextPageUrl!;
      final response = await _client.get(url, authenticate: true);
      final items = Items.fromJson(response);

      if (refresh) {
        _books = items.data;
      } else {
        _books.addAll(items.data);
      }

      _nextPageUrl = items.nextPageUrl == null || items.nextPageUrl == 'null'
          ? null
          : items.nextPageUrl;
    } catch (e) {
      if (refresh) _error = e.toString();
    } finally {
      _loading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }
}
