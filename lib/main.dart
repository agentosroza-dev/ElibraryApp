import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_favorites_provider.dart';
import 'screens/flash_screen.dart';
import 'utils/app_localizations.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => UserFavoritesProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}
