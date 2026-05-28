import '../config/api_config.dart';
import '../models/items_model.dart';
import '../models/trending_search.dart' as trending;
import '../models/suggested_search.dart' as suggested;
import '../services/api_client.dart';

class SearchLogic {
  final ApiClient _client = ApiClient();

  Future<({
    List<trending.Datum> trending,
    List<suggested.Datum> suggested,
  })> fetchInitialData() async {
    final results = await Future.wait([
      _client.get(ApiConfig.searchTrending, authenticate: true),
      _client.get(ApiConfig.searchSuggested, authenticate: true),
    ]);
    final t = trending.Trending.fromJson(results[0]);
    final s = suggested.Suggested.fromJson(results[1]);
    return (trending: t.data, suggested: s.data);
  }

  Future<ItemData> fetchItemDetail(String itemId) async {
    final response = await _client.get(
      ApiConfig.item(int.parse(itemId)),
      authenticate: true,
    );
    final itemJson = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    return ItemData.fromJson(itemJson);
  }
}
