import 'package:flutter/material.dart';
import 'package:smart_farmer_app/data/api/api_service.dart';
import 'package:smart_farmer_app/data/local/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  HomeProvider({required this.apiService, required this.authRepository});

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  Future<void> onItemTapped(int index) async {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<bool> logout() async {
    try {
      await authRepository.deleteUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint(e.toString());
    }
    await authRepository.saveState(false);
    notifyListeners();

    return true;
  }
}
