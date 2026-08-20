import 'dart:async';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class ProfileRepository {
  Future<AppResponse> getAppVersion({
    required String version,
    required String platform,
  }) {
    return sl.get<SecureApiService>().getAppVersion(
      version: version,
      platform: platform,
    );
  }

  Future<AppResponse> getProfileInfo() {
    return sl.get<SecureApiService>().getProfileInfo();
  }

  Future<AppResponse> getUserInfo() {
    return sl.get<SecureApiService>().getUserInfo();
  }

  Future<AppResponse> editPassword({
    required String oldPassword,
    required String newPassword,
    required confirmPassword,
  }) {
    return sl.get<SecureApiService>().editPassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  Future<AppResponse> updateProfile({
    required String firstName,
    required String lastName,
    required String imageId,
  }) {
    return sl.get<SecureApiService>().updateProfile(
      firstName: firstName,
      lastName: lastName,
      imageId: imageId,
    );
  }

  Future<AppResponse> postFCMToken({
    required String fcmToken,
    required String platform,
  }) {
    return sl.get<SecureApiService>().postFCMToken(
      fcmToken: fcmToken,
      platform: platform,
    );
  }
}
