import 'package:dio/dio.dart';
import 'package:fastnotes_flutter/core/exceptions/service_exception.dart';
import 'package:fastnotes_flutter/domain/repositories/auth_repository.dart';
import 'package:fastnotes_flutter/presentation/service_locator.dart';
import 'package:hive/hive.dart';

class AuthInterceptor extends Interceptor {
  final Box<dynamic> _hiveAuth = Hive.box('auth');
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final authData = _hiveAuth.get('auth');
      if (authData != null && authData is List && authData.length >= 2) {
        final token = authData[0];
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      throw ServiceException(e.toString());
    } finally {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 hatası alındığında token yenileme
    if (err.response?.statusCode == 401) {
      try {
        // Mevcut isteği geçici olarak sakla
        final originalRequest = err.requestOptions;

        // Token yenileme
        final authRepository = serviceLocator<AuthRepository>();
        final isRefreshed = await authRepository.refreshToken();

        if (isRefreshed) {
          // Yeni token'ı al
          final authData = _hiveAuth.get('auth');
          if (authData != null && authData is List && authData.length >= 3) {
            final newToken = authData[0];

            // Orijinal isteği yeni token ile tekrar gönder
            final response = await _dio.request(
              originalRequest.path,
              data: originalRequest.data,
              queryParameters: originalRequest.queryParameters,
              options: Options(
                method: originalRequest.method,
                headers: {
                  ...originalRequest.headers,
                  'Authorization': 'Bearer $newToken',
                },
              ),
            );

            // Başarılı cevabı işle
            return handler.resolve(response);
          }
        }
      } catch (e) {
        print('Token yenilenirken hata oluştu: $e');
      }
    }
    handler.next(err);
  }
}
