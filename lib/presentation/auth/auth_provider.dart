import 'package:fastnotes_flutter/domain/repositories/auth_repository.dart';
import 'package:fastnotes_flutter/presentation/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = serviceLocator<AuthRepository>();

  Future<bool> login() async {
    try {
      return await _authRepository.login();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> logout(BuildContext context) async {
    final result = await _authRepository.logout();
    if (result) {
      context.go('/auth');
    }
  }
}
