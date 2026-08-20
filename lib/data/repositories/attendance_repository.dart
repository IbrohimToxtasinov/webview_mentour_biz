import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class AttendanceRepository {
  Future<AppResponse> getLastAttendance() {
    return sl.get<SecureApiService>().getLastAttendance();
  }
}
