import 'dart:convert';

Recommended recommendedFromJson(String str) => Recommended.fromJson(json.decode(str));

String recommendedToJson(Recommended data) => json.encode(data.toJson());

class Recommended {
    String data;

    Recommended({
        required this.data,
    });

    factory Recommended.fromJson(Map<String, dynamic> json) => Recommended(
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
    };
}

class Datum {
    String id;
    String title;
    String authorId;
    String authorName;
    String coverUrl;
    String fileUrl;
    String categoryId;
    String categoryName;
    String createdAt;
    String updatedAt;
    List<Tag> tags;
    String matchedTagScore;
    String matchedTagCount;
    String favoriteScore;
    String viewsCount;
    String finalScore;

    Datum({
        required this.id,
        required this.title,
        required this.authorId,
        required this.authorName,
        required this.coverUrl,
        required this.fileUrl,
        required this.categoryId,
        required this.categoryName,
        required this.createdAt,
        required this.updatedAt,
        required this.tags,
        required this.matchedTagScore,
        required this.matchedTagCount,
        required this.favoriteScore,
        required this.viewsCount,
        required this.finalScore,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: '${json["id"]}',
        title: '${json["title"]}',
        authorId: '${json["author_id"]}',
        authorName: '${json["author_name"]}',
        coverUrl: '${json["cover_url"]}',
        fileUrl: '${json["file_url"]}',
        categoryId: '${json["category_id"]}',
        categoryName: '${json["category_name"]}',
        createdAt: '${json["created_at"]}',
        updatedAt: '${json["updated_at"]}',
        tags: json["tags"] is List
            ? List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x)))
            : [],
        matchedTagScore: '${json["matched_tag_score"]}',
        matchedTagCount: '${json["matched_tag_count"]}',
        favoriteScore: '${json["favorite_score"]}',
        viewsCount: '${json["views_count"]}',
        finalScore: '${json["final_score"]}',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "author_id": authorId,
        "author_name": authorName,
        "cover_url": coverUrl,
        "file_url": fileUrl,
        "category_id": categoryId,
        "category_name": categoryName,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
        "matched_tag_score": matchedTagScore,
        "matched_tag_count": matchedTagCount,
        "favorite_score": favoriteScore,
        "views_count": viewsCount,
        "final_score": finalScore,
    };
}

class Tag {
    String id;
    String name;

    Tag({
        required this.id,
        required this.name,
    });

    factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: '${json["id"]}',
        name: '${json["name"]}',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
