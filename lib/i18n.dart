import 'dart:ui' as ui;

/// Tiny two-language helper: English and Arabic, picked from the device locale.
bool get isArabic => ui.PlatformDispatcher.instance.locale.languageCode == 'ar';

String tr(String en, String ar) => isArabic ? ar : en;
