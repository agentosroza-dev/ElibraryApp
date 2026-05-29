import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/history_search_provider.dart';
import 'providers/home_provider.dart';
import 'providers/items_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/pdf_progress_provider.dart';
import 'providers/recommended_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_favorites_provider.dart';
import 'screens/flash_screen.dart';
import 'screens/items_details_screen.dart';
import 'services/local_notification_service.dart';
import 'utils/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => UserFavoritesProvider()),
        ChangeNotifierProvider(create: (_) => PdfProgressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => RecommendedProvider()),
        ChangeNotifierProvider(
          create: (_) => HistorySearchProvider()..load(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return _AppWithNotifications(child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'E-Library',
            debugShowCheckedModeBanner: false,
            theme: settings.isDark
                ? AppTheme.dark(fontScale: settings.fontScale)
                : AppTheme.light(fontScale: settings.fontScale),
            locale: settings.locale,
            supportedLocales: const [Locale('en'), Locale('km')],
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              ...GlobalMaterialLocalizations.delegates,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: const FlashScreen(),
          ));
        },
      ),
    );
  }
}

class _AppWithNotifications extends StatefulWidget {
  final Widget child;
  const _AppWithNotifications({required this.child});

  @override
  State<_AppWithNotifications> createState() => _AppWithNotificationsState();
}

class _AppWithNotificationsState extends State<_AppWithNotifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocalNotificationService.instance.initialize(
        onNotificationTap: (payload) {
          if (payload != null && payload.isNotEmpty) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => ItemsDetailsScreen.fromBookId(id: payload),
              ),
            );
          }
        },
      );
      context.read<NotificationsProvider>().startPolling();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
