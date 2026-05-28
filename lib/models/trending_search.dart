import 'dart:convert';

Trending trendingFromJson(String str) => Trending.fromJson(json.decode(str));

String trendingToJson(Trending data) => json.encode(data.toJson());

class Trending {
  List<Datum> data;

  Trending({
    required this.data,
  });

  factory Trending.fromJson(Map<String, dynamic> json) => Trending(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String name;
  String totalViews;
  String totalFavorites;
  String totalProgress;
  String totalInterest;
  String trendingScore;

  Datum({
    required this.id,
    required this.name,
    required this.totalViews,
    required this.totalFavorites,
    required this.totalProgress,
    required this.totalInterest,
    required this.trendingScore,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: '${json["id"]}',
        name: '${json["name"]}',
        totalViews: '${json["total_views"]}',
        totalFavorites: '${json["total_favorites"]}',
        totalProgress: '${json["total_progress"]}',
        totalInterest: '${json["total_interest"]}',
        trendingScore: '${json["trending_score"]}',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "total_views": totalViews,
        "total_favorites": totalFavorites,
        "total_progress": totalProgress,
        "total_interest": totalInterest,
        "trending_score": trendingScore,
      };
}
