import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart';

/// Returns the current device locale
Locale? getCurrentLocale() {
  return _localeFromString(Platform.localeName);
}

/// Returns preferred device locales
List<Locale>? getPreferredLocales() {
  // return WidgetsBinding.instance.window.locales;
  return PlatformDispatcher.instance.locales;
}

Locale? _localeFromString(String code) {
  String? separator = switch(code) {
    _ when code.contains('_') => '_',
    _ when code.contains('-') => '-',
    _ => null,
  };

  if (separator != null) {
    List<String> parts = code.split(RegExp(separator));
    return Locale(parts[0], parts[1]);
  } else {
    return Locale(code);
  }
}
