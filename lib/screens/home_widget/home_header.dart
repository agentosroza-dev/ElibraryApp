import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../screens/notifications_screen.dart';
import '../../utils/app_localizations.dart';
import '../../utils/font_scale.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationsProvider>();
    final unread = int.tryParse(notifProvider.unreadCount) ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${loc.translate('hello')}, ${auth.userName.isNotEmpty ? auth.userName : loc.translate('reader')}!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.sp(28),
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.translate('what_to_read'),
              style: TextStyle(
                fontSize: context.sp(15),
                  color: AppColors.iosGray,
                ),
              ),
            ],
          ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: cs.onSurface, size: 26),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.iosRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.iosCardDark : AppColors.iosCardLight,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.iosGray5, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark ? AppColors.iosGrayDark5 : AppColors.iosGray6,
                  backgroundImage: auth.userPhoto != null
                      ? CachedNetworkImageProvider(auth.userPhoto!)
                      : null,
                  child: auth.userPhoto == null
                      ? Icon(Icons.person, color: AppColors.iosGray, size: 24)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}