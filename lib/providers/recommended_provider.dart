import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/overall_recommended_books.dart';
import '../services/api_client.dart';

class RecommendedProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<RecommendedBook> _books = [];
  List<RecommendedBook> get books => _books;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchRecommended() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.get(
        ApiConfig.recommendedOverall,
        authenticate: true,
      );
      _books = OverallRecommendedBooks.fromJson(response).data;
    } catch (e) {
      _error = e.toString();
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
