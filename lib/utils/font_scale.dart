import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

extension FontScaleX on BuildContext {
  double sp(double size) {
    return size * read<SettingsProvider>().fontScale;
  }
}
