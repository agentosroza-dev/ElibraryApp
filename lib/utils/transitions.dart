import 'package:flutter/material.dart';

Route<T> fadeRoute<T>(
  Widget child, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

Route<T> slideRightToLeftRoute<T>(
  Widget child, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
