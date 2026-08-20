import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentour_web_view/blocs/tab/navigator_bloc.dart';
import 'package:mentour_web_view/data/repositories/singletons/secure_storage.dart';
import 'package:mentour_web_view/data/repositories/singletons/storage.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/services/interceptor/dio_logging_interceptor.dart';
import 'package:mentour_web_view/utils/app_constants.dart';
import 'package:mentour_web_view/utils/navigator_key.dart';

class SecureApiClient {
  late final Dio _refreshDio;

  final Dio dio;

  bool _isRefreshing = false;

  bool _isNavigatingToLogin = false;

  final List<Completer<String>> _refreshQueue = [];

  SecureApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(DioLoggingInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await StorageRepository.getInstance();

    final accessToken = await SecureStorage.get(key: 'accessToken');
    final lang = StorageRepository.getString('language');

    options.headers['X-Lang'] = lang.isEmpty ? 'en' : lang;
    options.headers['Accept'] = 'application/json';

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;

    if (error.requestOptions.path.contains('/api/v1/auth/token/refresh')) {
      if (statusCode == 400 || statusCode == 401) {
        await _handleLogout();
      }
      return handler.next(error);
    }

    if (statusCode != 401) {
      return handler.next(error);
    }

    final refreshToken = await SecureStorage.get(key: 'refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleLogout();
      return handler.next(error);
    }

    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshQueue.add(completer);

      try {
        final newToken = await completer.future;
        final retryResponse = await _retryRequest(
          error.requestOptions,
          newToken,
        );
        return handler.resolve(retryResponse);
      } catch (_) {
        return handler.next(error);
      }
    }

    _isRefreshing = true;

    try {
      final newAccessToken = await _refreshToken(refreshToken);

      for (final completer in _refreshQueue) {
        completer.complete(newAccessToken);
      }
      _refreshQueue.clear();
      _isRefreshing = false;

      final retryResponse = await _retryRequest(
        error.requestOptions,
        newAccessToken,
      );
      return handler.resolve(retryResponse);
    } on DioException catch (e) {
      _drainQueueWithError();

      final refreshStatus = e.response?.statusCode;
      if (refreshStatus == 400 || refreshStatus == 401) {
        await _handleLogout();
      }

      return handler.next(error);
    } catch (_) {
      _drainQueueWithError();
      await _handleLogout();
      return handler.next(error);
    }
  }

  Future<String> _refreshToken(String refreshToken) async {
    final response = await _refreshDio.post(
      '/api/v1/auth/token/refresh',
      data: {'token': refreshToken},
    );

    final data = response.data as Map<String, dynamic>?;
    final newAccessToken = data?['accessToken'] as String?;
    final newRefreshToken = data?['refreshToken'] as String?;

    if (newAccessToken == null || newAccessToken.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: 401,
          statusMessage: 'Unauthorized',
          data: response.data,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    await Future.wait([
      SecureStorage.save(key: 'accessToken', value: newAccessToken),
      if (newRefreshToken != null && newRefreshToken.isNotEmpty)
        SecureStorage.save(key: 'refreshToken', value: newRefreshToken),
    ]);

    debugPrint('🔑 Token refreshed successfully.');
    return newAccessToken;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions original,
    String newAccessToken,
  ) {
    final options = original.copyWith(
      headers: {...original.headers, 'Authorization': 'Bearer $newAccessToken'},
    );
    return dio.fetch(options);
  }

  void _drainQueueWithError() {
    for (final completer in _refreshQueue) {
      completer.completeError(Exception('Token refresh failed'));
    }
    _refreshQueue.clear();
    _isRefreshing = false;
  }

  Future<void> _handleLogout() async {
    if (_isNavigatingToLogin) return;
    _isNavigatingToLogin = true;

    await SecureStorage.deleteAll();

    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(AppRouterNames.splashRoute, (route) => false)
        .then((_) {
          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            context.read<NavigatorBloc>().add(ChangePageEvent(pageIndex: 0));
          }
          _isNavigatingToLogin = false;
        });

    debugPrint('🚪 Session expired — navigating to Sign-In.');
  }
}
