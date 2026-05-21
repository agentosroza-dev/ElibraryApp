import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/user_favorites.dart';
import '../services/api_client.dart';

class UserFavoritesProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<Favorite> _favorites = [];
  List<Favorite> get favorites => _favorites;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> fetchFavorites({bool refresh = false}) async {
    if (!refresh && _favorites.isNotEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.get(
        ApiConfig.userFavorites,
        authenticate: true,
      );
      final data = UserFavorites.fromJson(response);
      _favorites = data.favorites;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
