import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
      debugPrint('🌐 REQUEST');
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
      debugPrint('📍 URL: ${options.uri}');
      debugPrint('🔹 Method: ${options.method}');
      debugPrint('🔹 Headers:');
      options.headers.forEach((key, value) {
        debugPrint('   $key: $value');
      });
      if (options.queryParameters.isNotEmpty) {
        debugPrint('🔹 Query Parameters:');
        options.queryParameters.forEach((key, value) {
          debugPrint('   $key: $value');
        });
      }
      if (options.data != null) {
        debugPrint('🔹 Body:');
        if (options.data is FormData) {
          final formData = options.data as FormData;
          debugPrint('   FormData fields:');
          for (var field in formData.fields) {
            debugPrint('     ${field.key}: ${field.value}');
          }
          if (formData.files.isNotEmpty) {
            debugPrint('   FormData files:');
            for (var file in formData.files) {
              debugPrint('     ${file.key}: ${file.value.filename}');
            }
          }
        } else {
          debugPrint('   ${options.data}');
        }
      }
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
      debugPrint('✅ RESPONSE');
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
      debugPrint('📍 URL: ${response.requestOptions.uri}');
      debugPrint('🔹 Status Code: ${response.statusCode}');
      debugPrint('🔹 Status Message: ${response.statusMessage}');
      debugPrint('🔹 Headers:');
      response.headers.map.forEach((key, value) {
        debugPrint('   $key: ${value.join(", ")}');
      });
      debugPrint('🔹 Response Data:');
      try {
        final data = response.data;
        if (data is Map || data is List) {
          debugPrint('   ${_formatJson(data)}');
        } else {
          debugPrint('   $data');
        }
      } catch (e) {
        debugPrint('   ${response.data}');
      }
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if error is due to no internet connection
    if (_isNoInternetError(err)) {
      // Notify ConnectivityCubit about no internet
    }

    if (kDebugMode) {
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
      debugPrint('❌ ERROR');
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
      debugPrint('📍 URL: ${err.requestOptions.uri}');
      debugPrint('🔹 Method: ${err.requestOptions.method}');
      debugPrint('🔹 Error Type: ${err.type}');
      debugPrint('🔹 Error Message: ${err.message}');
      if (err.response != null) {
        debugPrint('🔹 Status Code: ${err.response?.statusCode}');
        debugPrint('🔹 Status Message: ${err.response?.statusMessage}');
        debugPrint('🔹 Response Headers:');
        err.response?.headers.map.forEach((key, value) {
          debugPrint('   $key: ${value.join(", ")}');
        });
        debugPrint('🔹 Error Response Data:');
        try {
          final data = err.response?.data;
          if (data is Map || data is List) {
            debugPrint('   ${_formatJson(data)}');
          } else {
            debugPrint('   $data');
          }
        } catch (e) {
          debugPrint('   ${err.response?.data}');
        }
      } else {
        debugPrint('🔹 No response received');
      }
      debugPrint(
        '═══════════════════════════════════════════════════════════════',
      );
    }
    super.onError(err, handler);
  }

  bool _isNoInternetError(DioException err) {
    // Check for connection errors that indicate no internet
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        (err.type == DioExceptionType.unknown &&
            err.message?.toLowerCase().contains('socket') == true) ||
        (err.message?.toLowerCase().contains('network') == true) ||
        (err.message?.toLowerCase().contains('internet') == true) ||
        (err.message?.toLowerCase().contains('failed host lookup') == true);
  }

  String _formatJson(dynamic data) {
    try {
      if (data is Map) {
        return data.toString();
      } else if (data is List) {
        return data.toString();
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }
}
