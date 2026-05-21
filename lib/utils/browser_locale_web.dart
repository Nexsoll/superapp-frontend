// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

String browserLanguageCode() {
  final language = html.window.navigator.language.trim();
  if (language.isEmpty) return '';
  return language.split('-').first.toLowerCase();
}
