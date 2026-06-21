import 'package:flutter/foundation.dart';

enum AppLogColor { red, green, blue, gray }

class AppLogger {
  AppLogger._();

  static const String _reset = '\x1B[0m';

  static String _ansi(AppLogColor c) {
    switch (c) {
      case AppLogColor.red:
        return '\x1B[31m'; // red
      case AppLogColor.green:
        return '\x1B[32m'; // green
      case AppLogColor.blue:
        return '\x1B[34m'; // blue
      case AppLogColor.gray:
        return '\x1B[90m'; // gray
    }
  }

  static void _log(
    Object msg, {
    AppLogColor color = AppLogColor.gray,
    String? tag,
    DateTime? time,
  }) {
    if (!kDebugMode) return; // don't log in release

    final t = (time ?? DateTime.now()).toIso8601String();
    final prefix = tag == null ? '[$t] ' : '[$t][$tag] ';
    final text = '$prefix$msg';

    debugPrint('${_ansi(color)}$text$_reset');
  }

  // Convenience methods
  static void red(Object msg, {String? tag}) =>
      _log(msg, color: AppLogColor.red, tag: tag);

  static void green(Object msg, {String? tag}) =>
      _log(msg, color: AppLogColor.green, tag: tag);

  static void blue(Object msg, {String? tag}) =>
      _log(msg, color: AppLogColor.blue, tag: tag);

  static void plain(Object msg, {String? tag}) =>
      _log(msg, color: AppLogColor.gray, tag: tag);
}
