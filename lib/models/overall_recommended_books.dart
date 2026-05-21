class OverallRecommendedBooks {
  List<RecommendedBook> data;

  OverallRecommendedBooks({required this.data});

  factory OverallRecommendedBooks.fromJson(Map<String, dynamic> json) =>
      OverallRecommendedBooks(
        data: json["data"] is List
            ? List<RecommendedBook>.from(
                json["data"].map((x) => RecommendedBook.fromJson(x)))
            : [],
      );
}

class RecommendedBook {
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
  List<BookTag> tags;
  String viewsCount;
  String popularityScore;
  String favoriteScore;
  String matchedTagScore;
  String matchedTagCount;
  String readProgressPercent;
  String readProgressScore;
  String recencyScore;
  String finalScore;

  RecommendedBook({
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
    required this.viewsCount,
    required this.popularityScore,
    required this.favoriteScore,
    required this.matchedTagScore,
    required this.matchedTagCount,
    required this.readProgressPercent,
    required this.readProgressScore,
    required this.recencyScore,
    required this.finalScore,
  });

  factory RecommendedBook.fromJson(Map<String, dynamic> json) =>
      RecommendedBook(
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
            ? List<BookTag>.from(
                json["tags"].map((x) => BookTag.fromJson(x)))
            : [],
        viewsCount: '${json["views_count"]}',
        popularityScore: '${json["popularity_score"]}',
        favoriteScore: '${json["favorite_score"]}',
        matchedTagScore: '${json["matched_tag_score"]}',
        matchedTagCount: '${json["matched_tag_count"]}',
        readProgressPercent: '${json["read_progress_percent"]}',
        readProgressScore: '${json["read_progress_score"]}',
        recencyScore: '${json["recency_score"]}',
        finalScore: '${json["final_score"]}',
      );
}

class BookTag {
  String id;
  String name;

  BookTag({required this.id, required this.name});

  factory BookTag.fromJson(Map<String, dynamic> json) => BookTag(
        id: '${json["id"]}',
        name: '${json["name"]}',
      );
}
