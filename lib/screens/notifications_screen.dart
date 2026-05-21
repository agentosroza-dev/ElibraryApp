import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/notifications_model.dart';
import '../providers/notifications_provider.dart';
import 'items_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationsProvider>().fetchNotifications(refresh: true);
    }
  }

  String _relativeTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.month}/${date.day}';
    } catch (_) {
      return '';
    }
  }

  List<NotificationItem> _section(String title, List<NotificationItem> items) {
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.iosGroupedBgDark : AppColors.iosGroupedBgLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        actions: [
          if (provider.notificationList.isNotEmpty) ...[
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text('Mark All Read'),
            ),
            TextButton(
              onPressed: () => provider.clearAll(),
              child: Text('Clear', style: TextStyle(color: cs.error)),
            ),
          ],
        ],
      ),
      body: _buildBody(context, cs, isDark, provider),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme cs, bool isDark,
      NotificationsProvider provider) {
    if (provider.loading) {
      return const Center(
        child: SpinKitFadingCircle(color: AppColors.iosBlue, size: 36),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40,
                  color: cs.error.withValues(alpha: 0.7)),
              const SizedBox(height: 12),
              Text(provider.error!,
                  style: TextStyle(color: cs.error, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => provider.fetchNotifications(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.notificationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 48, color: AppColors.iosGray),
            const SizedBox(height: 12),
            Text('No notifications',
                style: TextStyle(color: AppColors.iosGray, fontSize: 16)),
          ],
        ),
      );
    }

    final today = <NotificationItem>[];
    final yesterday = <NotificationItem>[];
    final earlier = <NotificationItem>[];

    final now = DateTime.now();
    for (final item in provider.notificationList) {
      final date = DateTime.tryParse(item.createdAt);
      if (date == null) {
        earlier.add(item);
      } else {
        final diff = now.difference(date);
        if (diff.inDays == 0) {
          today.add(item);
        } else if (diff.inDays == 1) {
          yesterday.add(item);
        } else {
          earlier.add(item);
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchNotifications(refresh: true),
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          if (today.isNotEmpty) _buildSection(context, cs, isDark, 'Today', today, provider),
          if (yesterday.isNotEmpty) _buildSection(context, cs, isDark, 'Yesterday', yesterday, provider),
          if (earlier.isNotEmpty) _buildSection(context, cs, isDark, 'Earlier', earlier, provider),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, ColorScheme cs, bool isDark,
      String title, List<NotificationItem> items, NotificationsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.iosGray,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final isLast = index == items.length - 1;
                return Column(
                  children: [
                    _buildNotificationTile(context, cs, isDark, items[index], provider),
                    if (!isLast)
                      Divider(height: 0, indent: 60,
                          color: isDark
                              ? AppColors.iosSeparatorDark.withValues(alpha: 0.3)
                              : AppColors.iosSeparatorLight.withValues(alpha: 0.08)),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(BuildContext context, ColorScheme cs, bool isDark,
      NotificationItem notif, NotificationsProvider provider) {
    final isUnread = notif.readAt == 'null' || notif.readAt.isEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isUnread) provider.markAsRead(notif.id);
          if (notif.itemId.isNotEmpty && notif.itemId != 'null') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemsDetailsScreen.fromBookId(
                  id: notif.itemId,
                  title: notif.title,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.notifications_outlined,
                        size: 20, color: cs.primary),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.iosBlue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 15,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeTime(notif.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.iosGray,
                          ),
                        ),
                      ],
                    ),
                    if (notif.message.isNotEmpty && notif.message != 'null') ...[
                      const SizedBox(height: 2),
                      Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.iosGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
