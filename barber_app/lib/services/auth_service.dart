import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import 'firebase_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase instances
  final firebase_auth.FirebaseAuth _auth = FirebaseService().auth;
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  // Stream controller for auth state changes
  final _authStateController = StreamController<User?>.broadcast();
  Stream<User?> get authStateChanges => _authStateController.stream;

  // Current user
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Initialize auth state
  Future<void> init() async {
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
      if (firebaseUser != null) {
        // Get user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          _currentUser = User.fromMap({
            'id': firebaseUser.uid,
            ...userDoc.data() as Map<String, dynamic>,
          });
        } else {
          // Create new user document if it doesn't exist
          final newUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Usuário',
            email: firebaseUser.email ?? '',
            phoneNumber: firebaseUser.phoneNumber ?? '',
            photoUrl: firebaseUser.photoURL,
          );

          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(newUser.toMap());
          _currentUser = newUser;
        }
      } else {
        _currentUser = null;
      }

      _authStateController.add(_currentUser);
    });

    // Check if user is already logged in
    final currentFirebaseUser = _auth.currentUser;
    if (currentFirebaseUser != null) {
      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .get();

      if (userDoc.exists) {
        _currentUser = User.fromMap({
          'id': currentFirebaseUser.uid,
          ...userDoc.data() as Map<String, dynamic>,
        });
        _authStateController.add(_currentUser);
      }
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Falha ao fazer login');
      }

      // Get user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        _currentUser = User.fromMap({
          'id': firebaseUser.uid,
          ...userDoc.data() as Map<String, dynamic>,
        });
      } else {
        throw Exception('Usuário não encontrado');
      }

      _authStateController.add(_currentUser);
      return _currentUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email não encontrado');
        case 'wrong-password':
          throw Exception('Senha incorreta');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-disabled':
          throw Exception('Usuário desativado');
        default:
          throw Exception('Erro ao fazer login: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // Sign up with email and password
  Future<User?> signUp(
      String name, String email, String password, String phoneNumber) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Falha ao criar conta');
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user document in Firestore
      final newUser = User(
        id: firebaseUser.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        photoUrl: null,
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());

      _currentUser = newUser;
      _authStateController.add(_currentUser);
      return _currentUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email já está em uso');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'weak-password':
          throw Exception('Senha muito fraca');
        default:
          throw Exception('Erro ao criar conta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _authStateController.add(null);
  }

  // Update user profile
  Future<User?> updateProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null || _currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Update display name if provided
      if (name != null) {
        await firebaseUser.updateDisplayName(name);
      }

      // Update user document in Firestore
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update(updates);

      // Update current user
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
      );

      _authStateController.add(_currentUser);
      return _currentUser;
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-not-found':
          throw Exception('Email não encontrado');
        default:
          throw Exception('Erro ao redefinir senha: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao redefinir senha: $e');
    }
  }

  // Dispose
  void dispose() {
    _authStateController.close();
  }
}
