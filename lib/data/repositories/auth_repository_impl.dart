import 'package:fastnotes_flutter/core/exceptions/repository_exception.dart';
import 'package:fastnotes_flutter/core/exceptions/service_exception.dart';
import 'package:fastnotes_flutter/data/services/auth_service.dart';
import 'package:fastnotes_flutter/domain/repositories/auth_repository.dart';
import 'package:hive/hive.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final Box<dynamic> _hiveAuth;
  final Box<dynamic> _hiveUser;

  AuthRepositoryImpl({required AuthService authService})
    : _authService = authService,
      _hiveAuth = Hive.box('auth'),
      _hiveUser = Hive.box('user');

  @override
  Future<bool> login() async {
    try {
      final authModel = await _authService.login();
      if (authModel == null) {
        return false;
      }

      // Önce token bilgilerini kaydet
      _hiveAuth.put('auth', [
        authModel.token,
        authModel.refreshToken,
        authModel.userId,
      ]);

      // Sonra kullanıcı bilgilerini al
      await getLoggedInUser();

      return true;
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _hiveAuth.get('auth')[1];
      final authModel = await _authService.refreshToken(refreshToken);
      if (authModel == null) {
        return false;
      }

      _hiveAuth.put('auth', [
        authModel.token,
        authModel.refreshToken,
        authModel.userId,
      ]);

      return true;
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      _hiveAuth.delete('auth');
      _hiveUser.delete('user');
      final result = await _authService.logout();
      if (result) {
        return true;
      }
      return false;
    } on ServiceException catch (e) {
      throw RepositoryException(e.message, originalError: e);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  bool isUserLoggedIn() {
    try {
      final authData = _hiveAuth.get('auth');
      final userData = _hiveUser.get('user');
      if (authData != null &&
          authData is List &&
          authData.length >= 3 &&
          userData != null &&
          userData is List &&
          userData.length >= 3) {
        // Token var, ancak süresini kontrol etmiyoruz
        // JWT token'ın süresi server tarafında kontrol edilecek
        return true;
      }
      return false;
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }

  @override
  Future<void> getLoggedInUser() async {
    try {
      final user = await _authService.getLoggedInUser();
      if (user == null) {
        throw RepositoryException('Kullanıcı bulunamadı');
      }

      // Kullanıcı bilgilerini Hive'a kaydet
      _hiveUser.put('user', [
        user.displayName,
        user.email,
        user.photoUrl,
      ]);
    } catch (e) {
      throw RepositoryException(e.toString());
    }
  }
}
