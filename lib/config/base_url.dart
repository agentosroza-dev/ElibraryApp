import 'package:flutter/foundation.dart';

class BaseURL {
  static String get base =>
      kReleaseMode ? 'https://code-blue.cloud' : 'https://code-blue.cloud';
}
