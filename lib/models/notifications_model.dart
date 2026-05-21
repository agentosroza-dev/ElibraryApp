class Notifications {
  String notifications;
  String unreadCount;

  Notifications({
    required this.notifications,
    required this.unreadCount,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        notifications: '${json["notifications"]}',
        unreadCount: '${json["unread_count"]}',
      );
}

class NotificationItem {
  String id;
  String userId;
  String type;
  String title;
  String message;
  String itemId;
  String readAt;
  String createdAt;
  String updatedAt;
  String item;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.itemId,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    required this.item,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: '${json["id"]}',
        userId: '${json["user_id"]}',
        type: '${json["type"]}',
        title: '${json["title"]}',
        message: '${json["message"]}',
        itemId: '${json["item_id"]}',
        readAt: '${json["read_at"]}',
        createdAt: '${json["created_at"]}',
        updatedAt: '${json["updated_at"]}',
        item: '${json["item"]}',
      );
}

class Item {
  String id;
  String title;
  String slug;
  String coverUrl;

  Item({
    required this.id,
    required this.title,
    required this.slug,
    required this.coverUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: '${json["id"]}',
        title: '${json["title"]}',
        slug: '${json["slug"]}',
        coverUrl: '${json["cover_url"]}',
      );
}
