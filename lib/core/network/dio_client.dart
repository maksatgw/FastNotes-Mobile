import 'package:dio/dio.dart';
import 'package:fastnotes_flutter/app/config/app_constants.dart';
import 'package:fastnotes_flutter/core/network/auth_intecreptor.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  static Dio get instance => _dio;

  static void setupInterceptors() {
    _dio.interceptors.add(AuthInterceptor(_dio));
  }
}
