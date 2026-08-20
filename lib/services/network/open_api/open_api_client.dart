import 'package:dio/dio.dart';
import 'package:mentour_web_view/data/repositories/singletons/storage.dart';
import 'package:mentour_web_view/services/interceptor/dio_logging_interceptor.dart';
import 'package:mentour_web_view/utils/app_constants.dart';

class OpenApiClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  OpenApiClient() {
    dio.interceptors.add(DioLoggingInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await StorageRepository.getInstance();
          final lang = StorageRepository.getString('language');
          options.headers['X-Lang'] = lang.isEmpty ? 'en' : lang;
          options.headers["accept"] = "*/*";
          options.headers["Content-Type"] = "application/json";

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }
}
