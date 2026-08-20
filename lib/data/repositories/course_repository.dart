import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class CourseRepository {
  Future<AppResponse> getStudentAllCourses({required int page}) {
    return sl.get<SecureApiService>().getMyCourses(page: page);
  }

  Future<AppResponse> getCourseById({required String courseId}) {
    return sl.get<SecureApiService>().getCourseById(courseId: courseId);
  }

  Future<AppResponse> getCourseGroupDetails({required String courseId}) {
    return sl.get<SecureApiService>().getCourseGroupDetails(courseId: courseId);
  }
}
