import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${loc.translate('hello')}, ${auth.userName.isNotEmpty ? auth.userName : loc.translate('reader')}!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.translate('what_to_read'),
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.iosGray,
                ),
              ),
            ],
          ),
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
    );
  }
}
