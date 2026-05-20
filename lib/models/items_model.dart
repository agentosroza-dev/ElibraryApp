class Items {
  String currentPage;
  List<ItemData> data;
  String firstPageUrl;
  String from;
  String lastPage;
  String lastPageUrl;
  List<Link> links;
  String? nextPageUrl;
  String path;
  String perPage;
  String? prevPageUrl;
  String to;
  String total;

  Items({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    currentPage: '${json["current_page"]}',
    data: List<ItemData>.from(json["data"].map((x) => ItemData.fromJson(x))),
    firstPageUrl: '${json["first_page_url"]}',
    from: '${json["from"]}',
    lastPage: '${json["last_page"]}',
    lastPageUrl: '${json["last_page_url"]}',
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"] != null ? '${json["next_page_url"]}' : null,
    path: '${json["path"]}',
    perPage: '${json["per_page"]}',
    prevPageUrl: json["prev_page_url"] != null ? '${json["prev_page_url"]}' : null,
    to: '${json["to"]}',
    total: '${json["total"]}',
  );
}

class ItemData {
  String id;
  String title;
  String slug;
  String? description;
  String? coverUrl;
  String? fileUrl;
  String categoryId;
  String authorId;
  String? publishYear;
  String? pages;
  String? language;
  String isActive;
  String userIdCreated;
  String? userIdUpdated;
  String createdAt;
  String updatedAt;
  String? viewsCount;
  Category category;
  Author author;
  List<Tag> tags;

  ItemData({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.coverUrl,
    this.fileUrl,
    required this.categoryId,
    required this.authorId,
    this.publishYear,
    this.pages,
    this.language,
    required this.isActive,
    required this.userIdCreated,
    this.userIdUpdated,
    required this.createdAt,
    required this.updatedAt,
    this.viewsCount,
    required this.category,
    required this.author,
    required this.tags,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) => ItemData(
    id: '${json["id"]}',
    title: '${json["title"]}',
    slug: json["slug"] != null ? '${json["slug"]}' : '',
    description: json["description"] != null ? '${json["description"]}' : null,
    coverUrl: json["cover_url"] != null ? '${json["cover_url"]}' : null,
    fileUrl: json["file_url"] != null ? '${json["file_url"]}' : null,
    categoryId: json["category_id"] != null ? '${json["category_id"]}' : '',
    authorId: json["author_id"] != null ? '${json["author_id"]}' : '',
    publishYear: json["publish_year"] != null ? '${json["publish_year"]}' : null,
    pages: json["pages"] != null ? '${json["pages"]}' : null,
    language: json["language"] != null ? '${json["language"]}' : null,
    isActive: json["is_active"] != null ? '${json["is_active"]}' : '1',
    userIdCreated: json["user_id_created"] != null ? '${json["user_id_created"]}' : '',
    userIdUpdated: json["user_id_updated"] != null ? '${json["user_id_updated"]}' : null,
    createdAt: json["created_at"] != null ? '${json["created_at"]}' : '',
    updatedAt: json["updated_at"] != null ? '${json["updated_at"]}' : '',
    viewsCount: json["views_count"] != null ? '${json["views_count"]}' : null,
    category: json["category"] != null
        ? Category.fromJson(json["category"])
        : Category(id: '0', name: ''),
    author: json["author"] != null
        ? Author.fromJson(json["author"])
        : Author(id: '0', name: json["author_name"] ?? '', email: ''),
    tags: json["tags"] != null
        ? List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x)))
        : [],
  );

  String get authorName => author.name.isNotEmpty ? author.name : (author.email.isNotEmpty ? author.email : '');
  String get categoryName => category.name;
}

class Author {
  String id;
  String name;
  String email;

  Author({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: '${json["id"]}',
    name: '${json["name"]}',
    email: '${json["email"]}',
  );
}

class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: '${json["id"]}',
    name: '${json["name"]}',
  );
}

class Tag {
  String id;
  String name;
  TagPivot? pivot;

  Tag({
    required this.id,
    required this.name,
    this.pivot,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    id: '${json["id"]}',
    name: '${json["name"]}',
    pivot: json["pivot"] != null ? TagPivot.fromJson(json["pivot"]) : null,
  );
}

class TagPivot {
  String bookId;
  String tagId;
  String createdAt;
  String updatedAt;

  TagPivot({
    required this.bookId,
    required this.tagId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TagPivot.fromJson(Map<String, dynamic> json) => TagPivot(
    bookId: '${json["book_id"]}',
    tagId: '${json["tag_id"]}',
    createdAt: '${json["created_at"]}',
    updatedAt: '${json["updated_at"]}',
  );
}

class Link {
  String? url;
  String label;
  String? page;
  String active;

  Link({
    this.url,
    required this.label,
    this.page,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"] != null ? '${json["url"]}' : null,
    label: '${json["label"]}',
    page: json["page"] != null ? '${json["page"]}' : null,
    active: '${json["active"]}',
  );
}
