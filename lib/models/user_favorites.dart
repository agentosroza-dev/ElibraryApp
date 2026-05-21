class UserFavorites {
  List<Favorite> favorites;

  UserFavorites({required this.favorites});

  factory UserFavorites.fromJson(Map<String, dynamic> json) => UserFavorites(
        favorites: json["data"] is List
            ? List<Favorite>.from(
                json["data"].map((x) => Favorite.fromJson(x)))
            : json["favorites"] is List
                ? List<Favorite>.from(
                    json["favorites"].map((x) => Favorite.fromJson(x)))
                : [],
      );
}

class Favorite {
  String id;
  String title;
  String author;
  String image;
  List<String> tags;

  Favorite({
    required this.id,
    required this.title,
    required this.author,
    required this.image,
    required this.tags,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: '${json["id"]}',
        title: '${json["title"]}',
        author: '${json["author_name"] ?? json["author"] ?? ''}',
        image: '${json["cover_url"] ?? json["image"] ?? ''}',
        tags: json["tags"] is List
            ? List<String>.from(json["tags"].map((x) => '$x'))
            : [],
      );
}
