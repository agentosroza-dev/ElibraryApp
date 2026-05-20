class Categories {
  String id;
  String name;
  String slug;
  String description;
  String isActive;
  String createdAt;
  String updatedAt;

  Categories({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
        id: '${json["id"]}',
        name: '${json["name"]}',
        slug: '${json["slug"]}',
        description: '${json["description"]}',
        isActive: '${json["is_active"]}',
        createdAt: '${json["created_at"]}',
        updatedAt: '${json["updated_at"]}',
      );
}
