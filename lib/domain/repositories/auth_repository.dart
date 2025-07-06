abstract class AuthRepository {
  Future<bool> login();
  Future<bool> refreshToken();
  Future<bool> logout();
  Future<void> getLoggedInUser();
  bool isUserLoggedIn();
}
