import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_bottom_nav_bar/liquid_bottom_nav_bar.dart';
import '../config/theme.dart';
import '../utils/app_localizations.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isNavBarVisible = true;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  void _onTabChanged(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          if (!_isNavBarVisible) {
            setState(() => _isNavBarVisible = true);
          }
          break;
        case ScrollDirection.reverse:
          if (_isNavBarVisible) {
            setState(() => _isNavBarVisible = false);
          }
          break;
        case ScrollDirection.idle:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final items = [
      LiquidNavItem(
        icon: Icons.book_outlined,
        activeIcon: Icons.book,
        label: loc.translate('home'),
      ),
      LiquidNavItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: loc.translate('search'),
      ),
      LiquidNavItem(
        icon: Icons.library_books_outlined,
        activeIcon: Icons.library_books,
        label: loc.translate('library'),
      ),
      LiquidNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: loc.translate('profile'),
      ),
    ];

    final labelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.iosGray,
    );

    final activeLabelStyle = GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: cs.primary,
    );

    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _handleScrollNotification(notification);
              return false;
            },
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          if (_isNavBarVisible)
            Positioned(
              left: 8,
              right: 8,
              bottom: bottomPad - 12,
              child: LiquidBottomNavBar(
                currentIndex: _currentIndex,
                items: items,
                onTap: _onTabChanged,
                onDrag: _onTabChanged,
                showLabel: true,
                blurSigma: 8,
                height: 68,
                style: LiquidNavStyle(
                  backgroundColor: Colors.transparent,
                  containerColor: isDark
                      ? AppColors.iosGrayDark5
                      : AppColors.iosCardLight,
                  liquidColor: cs.primary.withValues(alpha: 0.15),
                  activeIconColor: cs.primary,
                  inactiveIconColor: AppColors.iosGray,
                  labelStyle: labelStyle,
                  activeLabelStyle: activeLabelStyle,
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.iosSeparatorDark.withValues(alpha: 0.1)
                        : AppColors.iosSeparatorLight.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}