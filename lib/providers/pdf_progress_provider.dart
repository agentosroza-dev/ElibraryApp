import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/pdf_progress_model.dart';
import '../services/api_client.dart';

class PdfProgressProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<Datum> _progressList = [];
  List<Datum> get progressList => _progressList;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> fetchProgressList({bool refresh = false}) async {
    if (!refresh && _progressList.isNotEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.get(
        ApiConfig.pdfProgressList,
        authenticate: true,
      );
      final list = response['data'] as List;
      _progressList = list
          .map((x) => Datum.fromJson(x as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> saveProgress({
    required String itemId,
    required String lastPage,
    required String totalPages,
    String percent = '',
    String docKey = '',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'item_id': itemId,
        'last_page': lastPage,
        'total_pages': totalPages,
      };
      if (percent.isNotEmpty) body['percent'] = percent;
      if (docKey.isNotEmpty) body['doc_key'] = docKey;

      await _client.post(
        ApiConfig.pdfProgress,
        body: body,
        authenticate: true,
      );
      await fetchProgressList(refresh: true);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
