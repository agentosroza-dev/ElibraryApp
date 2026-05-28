import 'dart:convert';

Suggested suggestedFromJson(String str) => Suggested.fromJson(json.decode(str));

String suggestedToJson(Suggested data) => json.encode(data.toJson());

class Suggested {
  List<Datum> data;

  Suggested({
    required this.data,
  });

  factory Suggested.fromJson(Map<String, dynamic> json) => Suggested(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String id;
  String title;
  String description;
  String fileUrl;
  Author category;
  Author author;
  List<Author> tags;
  String coverUrl;
  String viewsCount;
  String searchScore;
  String createdAt;
  String status;
  String suggestedScore;

  Datum({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.category,
    required this.author,
    required this.tags,
    required this.coverUrl,
    required this.viewsCount,
    required this.searchScore,
    required this.createdAt,
    required this.status,
    required this.suggestedScore,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: '${json["id"]}',
        title: '${json["title"]}',
        description: '${json["description"]}',
        fileUrl: '${json["file_url"]}',
        category: Author.fromJson(json["category"]),
        author: Author.fromJson(json["author"]),
        tags: List<Author>.from(json["tags"].map((x) => Author.fromJson(x))),
        coverUrl: '${json["cover_url"]}',
        viewsCount: '${json["views_count"]}',
        searchScore: '${json["search_score"]}',
        createdAt: '${json["created_at"]}',
        status: '${json["status"]}',
        suggestedScore: '${json["suggested_score"]}',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "file_url": fileUrl,
        "category": category.toJson(),
        "author": author.toJson(),
        "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
        "cover_url": coverUrl,
        "views_count": viewsCount,
        "search_score": searchScore,
        "created_at": createdAt,
        "status": status,
        "suggested_score": suggestedScore,
      };
}

class Author {
  String id;
  String name;

  Author({
    required this.id,
    required this.name,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        id: '${json["id"]}',
        name: '${json["name"]}',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
