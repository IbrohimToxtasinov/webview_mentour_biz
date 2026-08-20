import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/utils/app_constants.dart';
import 'package:mentour_web_view/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  const AppUtils._();

  static Color levelColors(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return const Color(0xFF2D60FF);
      case 'INTERMEDIATE':
        return const Color(0xFF790AC4);
      case 'ADVANCED':
        return const Color(0xFFA94B03);
      default:
        return const Color(0xFF2D60FF);
    }
  }

  static String getInitial(String name, [String fallback = "U"]) {
    if (name.isEmpty) return fallback;
    if (name.length >= 2) {
      String firstTwo = name.substring(0, 2).toLowerCase();
      if (firstTwo == "sh" || firstTwo == "ch") {
        return name[0].toUpperCase() + name[1].toLowerCase();
      }
    }
    return name[0].toUpperCase();
  }

  static Map<String, dynamic> listToAnswerMap(List<String> answers) {
    final Map<String, dynamic> result = {};

    for (int i = 0; i < answers.length; i++) {
      result[(i + 1).toString()] = answers[i];
    }

    return result;
  }

  static Future<void> launchLinks(
    String link, {
    LaunchMode launchMode = LaunchMode.platformDefault,
  }) async {
    if (await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link), mode: launchMode);
    }
  }

  static String getCurrentLanguageLabel(String language) {
    switch (language) {
      case 'en':
        return "English";
      case 'ru':
        return "Русский";
      case 'uz':
        return "O'zbekcha";
      case 'kaa':
        return "Qaraqalpaqsha";
      case 'tg':
        return "Тоҷикӣ";
      case 'ky':
        return "Кыргызча";
      default:
        return "O'zbekcha";
    }
  }

  static String formatDate(String dateString) {
    return DateFormat('dd.MM').format(DateTime.parse(dateString));
  }
  static String formatSum(num value) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(value).replaceAll(',', ' ');
  }

  static String getFormattedDateTime(BuildContext context, DateTime dateTime) {
    final nameMonth = dateTime.getMonthName(context: context);
    return '${dateTime.day} $nameMonth ${"${dateTime.year}"}';
  }

  static String newGetFormattedDateTime(
    BuildContext context,
    DateTime dateTime,
  ) {
    final nameMonth = dateTime.getMonthName(context: context);
    return '$nameMonth ${dateTime.day}, ${dateTime.formatDateTime(AppConstants.hhDpMm)}';
  }

  static String getFormatTime(BuildContext context, DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${"${dateTime.year}"}';
  }

  static DateTime parseUtcToLocal(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return dateTime.add(const Duration(hours: 5));
    } catch (e) {
      return DateTime.now();
    }
  }

  static String formatToDdMmYyyy(String isoString) {
    final dateTime = parseUtcToLocal(isoString);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return "$day.$month.$year";
  }

  static String getFormattedTime(BuildContext context, DateTime dateTime) {
    return dateTime.formatDateTime(AppConstants.hhDpMm);
  }

  static String themeModeToString(ThemeMode themMode) {
    switch (themMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  static ThemeMode themeModeFromString(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
