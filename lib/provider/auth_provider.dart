import 'package:flutter/material.dart';
import 'package:smart_farmer_app/common/loading_state.dart';
import 'package:smart_farmer_app/data/api/api_service.dart';
import 'package:smart_farmer_app/data/local/auth_repository.dart';
import 'package:smart_farmer_app/model/login.dart';
import 'package:smart_farmer_app/model/register.dart';
import 'package:smart_farmer_app/model/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  AuthProvider({required this.apiService, required this.authRepository}) {
    checkIsLoggedIn();
  }

  RegisterResponse? registerResponse;
  LoginResponse? loginResponse;

  LoadingState loadingState = const LoadingState.initial();

  String? _message;
  String? get message => _message;

  bool isLoggedIn = false;

  String? deviceToken;

  Future<bool> checkIsLoggedIn() async {
    loadingState = const LoadingState.loading();
    notifyListeners();

    try {
      isLoggedIn = await authRepository.getState();
      loadingState = const LoadingState.loaded();
      notifyListeners();
      return isLoggedIn;
    } catch (e) {
      loadingState = LoadingState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      loadingState = const LoadingState.loading();
      notifyListeners();

      registerResponse = await apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (registerResponse!.success) {
        loadingState = const LoadingState.loaded();
        _message = registerResponse!.message;

        final User user = User(
          email: email,
          token: registerResponse!.token,
        );

        await authRepository.saveUser(user);
        await authRepository.saveState(true);

        notifyListeners();
        return true;
      } else {
        _message = registerResponse!.message;
        loadingState = LoadingState.error(registerResponse!.message);
        notifyListeners();
        return false;
      }
    } catch (e) {
      loadingState = LoadingState.error(e.toString());
      _message = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      loadingState = const LoadingState.loading();
      notifyListeners();

      loginResponse = await apiService.login(
        email: email,
        password: password,
      );

      if (loginResponse!.success) {
        loadingState = const LoadingState.loaded();
        _message = loginResponse!.message;

        final User user = User(
          email: email,
          token: loginResponse!.token!,
        );

        await authRepository.saveUser(user);
        await authRepository.saveState(true);

        notifyListeners();
        return true;
      } else {
        _message = loginResponse!.message;
        loadingState = LoadingState.error(loginResponse!.message);
        debugPrint(loginResponse!.message);
        notifyListeners();
        return false;
      }
    } catch (e) {
      loadingState = LoadingState.error(e.toString());
      debugPrint(e.toString());
      _message = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.saveState(false);
    await authRepository.deleteUser();
    notifyListeners();
  }
}
