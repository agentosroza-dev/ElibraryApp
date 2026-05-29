import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistorySearchProvider extends ChangeNotifier {
  static const _maxItems = 5;
  static const _storageKey = 'search_history';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<String> _queries = [];
  List<String> get queries => _queries;

  Future<void> load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null) {
        _queries = (jsonDecode(raw) as List).cast<String>();
      }
    } catch (_) {}
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _queries.remove(q);
    _queries.insert(0, q);
    if (_queries.length > _maxItems) {
      _queries = _queries.sublist(0, _maxItems);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String query) async {
    _queries.remove(query);
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _queries = [];
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.write(key: _storageKey, value: jsonEncode(_queries));
  }
}
