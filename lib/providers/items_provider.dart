import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/items_model.dart';
import '../services/api_client.dart';

class ItemsProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<ItemData> _items = [];
  List<ItemData> get items => _items;

  ItemData? _selectedItem;
  ItemData? get selectedItem => _selectedItem;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingItem = false;
  bool get isLoadingItem => _isLoadingItem;

  String? _error;
  String? get error => _error;

  String? _nextPageUrl;
  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  bool get hasMore => _nextPageUrl != null;

  Future<void> fetchItems({bool refresh = false}) async {
    if (!refresh && _nextPageUrl == null && _items.isNotEmpty) return;
    if (_isFetchingMore) return;

    _isFetchingMore = true;
    if (refresh) {
      _isLoading = true;
      _error = null;
    }
    notifyListeners();

    try {
      final url = refresh || _nextPageUrl == null
          ? ApiConfig.items
          : _nextPageUrl!;
      final response = await _client.get(url, authenticate: true);
      final paginated = Items.fromJson(response);

      if (refresh) {
        _items = paginated.data;
      } else {
        _items.addAll(paginated.data);
      }

      _nextPageUrl = paginated.nextPageUrl == null || paginated.nextPageUrl == 'null'
          ? null
          : paginated.nextPageUrl;
    } catch (e) {
      if (refresh) _error = e.toString();
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchItem(int id) async {
    _isLoadingItem = true;
    _error = null;
    _selectedItem = null;
    notifyListeners();

    try {
      final response = await _client.get(
        ApiConfig.item(id),
        authenticate: true,
      );
      final data = response['data'] as Map<String, dynamic>? ?? response;
      _selectedItem = ItemData.fromJson(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingItem = false;
      notifyListeners();
    }
  }

  void clearSelectedItem() {
    _selectedItem = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
