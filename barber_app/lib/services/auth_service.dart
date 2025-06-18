import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Stream controller for auth state changes
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Current user
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Mock users for demo
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'Cliente Demo',
      'email': 'demo@example.com',
      'password': '123456', // In a real app, this would be hashed
      'phoneNumber': '11999999999',
    }
  ];

  // Initialize auth state
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (userId != null) {
      // Auto-login with stored user ID
      final userMap = _users.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => {},
      );
      
      if (userMap.isNotEmpty) {
        _currentUser = User.fromMap(userMap);
        _authStateController.add(_currentUser);
      }
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final userMap = _users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );
      
      if (userMap.isEmpty) {
        throw Exception('Credenciais inválidas');
      }
      
      _currentUser = User.fromMap(userMap);
      
      // Save user ID to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);
      
      _authStateController.add(_currentUser);
      return _currentUser;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<User?> signUp(String name, String email, String password, String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // Check if email already exists
      final existingUser = _users.any((user) => user['email'] == email);
      if (existingUser) {
        throw Exception('Email já está em uso');
      }
      
      // Create new user
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'password': password, // In a real app, this would be hashed
        'phoneNumber': phoneNumber,
        'favoriteBarbers': <String>[],
        'appointmentHistory': <String>[],
      };
      
      _users.add(newUser);
      _currentUser = User.fromMap(newUser);
      
      // Save user ID to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _currentUser!.id);
      
      _authStateController.add(_currentUser);
      return _currentUser;
    } catch (e) {
      _authStateController.add(null);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    
    // Clear stored user ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    
    _authStateController.add(null);
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}