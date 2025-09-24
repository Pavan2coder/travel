import 'dart:async';

class AuthService {
  String? _userId;

  String? get userId => _userId;
  bool get isLoggedIn => _userId != null;

  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _userId = email; // mock
    return true;
  }

  Future<bool> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _userId = email;
    return true;
  }

  Future<void> signOut() async {
    _userId = null;
  }
}

