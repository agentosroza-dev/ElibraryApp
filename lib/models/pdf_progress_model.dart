class PdfProgress {
  String message;
  String data;

  PdfProgress({
    required this.message,
    required this.data,
  });

  factory PdfProgress.fromJson(Map<String, dynamic> json) => PdfProgress(
        message: '${json["message"]}',
        data: '${json["data"]}',
      );
}

class Datum {
  String id;
  String itemId;
  String docKey;
  String lastPage;
  String totalPages;
  String percent;
  String createdAt;
  String updatedAt;
  String title;
  String coverUrl;
  String fileUrl;
  String authorName;
  String categoryName;
  String tags;

  Datum({
    required this.id,
    required this.itemId,
    required this.docKey,
    required this.lastPage,
    required this.totalPages,
    required this.percent,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.coverUrl,
    required this.fileUrl,
    required this.authorName,
    required this.categoryName,
    required this.tags,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: '${json["id"]}',
        itemId: '${json["item_id"]}',
        docKey: '${json["doc_key"]}',
        lastPage: '${json["last_page"]}',
        totalPages: '${json["total_pages"]}',
        percent: '${json["percent"]}',
        createdAt: '${json["created_at"]}',
        updatedAt: '${json["updated_at"]}',
        title: '${json["title"]}',
        coverUrl: '${json["cover_url"]}',
        fileUrl: '${json["file_url"]}',
        authorName: '${json["author_name"]}',
        categoryName: '${json["category_name"]}',
        tags: '${json["tags"]}',
      );
}
