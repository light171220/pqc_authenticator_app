import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/account.dart';
import '../utils/constants.dart';

class ApiService extends ChangeNotifier {
  String? _token;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    notifyListeners();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        _currentUser = User.fromJson(data['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        _currentUser = User.fromJson(data['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<List<Account>> getAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/accounts'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Account.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createAccount(Account account) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/accounts'),
        headers: _headers,
        body: jsonEncode(account.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.apiBaseUrl}/accounts/$accountId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }
}