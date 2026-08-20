import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String extractErrorMessage(DioException? error) {
  final responseData = error?.response?.data;
  if (responseData is Map && responseData.containsKey("message")) {
    return responseData["message"] ?? "data_fetch_error".tr();
  }
  return "data_fetch_error".tr();
}

extension MentourDateTimeExtension on DateTime {
  String getMonthName({required BuildContext context}) {
    switch (month) {
      case 1:
        return "january".tr();
      case 2:
        return "february".tr();
      case 3:
        return "march".tr();
      case 4:
        return "april".tr();
      case 5:
        return "may".tr();
      case 6:
        return "june".tr();
      case 7:
        return "july".tr();
      case 8:
        return "august".tr();
      case 9:
        return "september".tr();
      case 10:
        return "october".tr();
      case 11:
        return "november".tr();
      case 12:
        return "december".tr();
      default:
        return "invalid_month".tr();
    }
  }

  String formatDateTime(String? pattern) {
    final DateFormat formatter = DateFormat(pattern);
    final String formatted = formatter.format(this);
    return formatted;
  }

  bool get isYearLeap {
    if (year % 400 == 0) {
      return true;
    } else if (year % 100 == 0) {
      return false;
    } else {
      return year % 4 == 0;
    }
  }
}
