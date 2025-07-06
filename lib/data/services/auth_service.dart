import 'package:dio/dio.dart';
import 'package:fastnotes_flutter/app/config/app_constants.dart';
import 'package:fastnotes_flutter/core/exceptions/service_exception.dart';
import 'package:fastnotes_flutter/core/network/dio_client.dart';
import 'package:fastnotes_flutter/data/models/auth_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthService {
  Future<AuthModel?> login();
  Future<AuthModel?> refreshToken(String refreshToken);
  Future<GoogleSignInAccount?> getLoggedInUser();
  Future<bool> logout();
}

class AuthServiceImpl implements AuthService {
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  AuthServiceImpl()
    : _dio = DioClient.instance,
      _googleSignIn = GoogleSignIn(
        clientId:
            '1077192807490-f59guokn7ulco9r7o5mra4ug7fjgb4t3.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

  @override
  Future<AuthModel?> login() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw ServiceException('Google sign in failed');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await _dio.post(
        AppConstants.authPath,
        data: {
          'idToken': googleAuth.idToken,
        },
      );

      if (response.statusCode == 200) {
        final authModel = AuthModel.fromJson(response.data);
        return authModel;
      }
      throw ServiceException('Login failed');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServiceException('Connection timeout', statusCode: 408);
      }
      throw ServiceException(
        e.response?.data['message'],
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<AuthModel?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        AppConstants.authPath,
        data: {
          'refreshToken': refreshToken,
        },
      );
      if (response.statusCode == 200) {
        final authModel = AuthModel.fromJson(response.data);
        return authModel;
      }
      throw ServiceException('Refresh token failed');
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<GoogleSignInAccount?> getLoggedInUser() async {
    try {
      final user = _googleSignIn.currentUser;
      if (user == null) {
        throw ServiceException('User not found');
      }
      return user;
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      throw ServiceException(e.toString(), statusCode: 500);
    }
  }
}
