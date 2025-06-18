import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barber.dart';
import '../models/service.dart';
import 'firebase_service.dart';

class BarberService {
  // Singleton pattern
  static final BarberService _instance = BarberService._internal();
  factory BarberService() => _instance;
  BarberService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  // Stream controllers
  final _barbersController = StreamController<List<Barber>>.broadcast();
  final _servicesController = StreamController<List<Service>>.broadcast();

  // Streams
  Stream<List<Barber>> get barbersStream => _barbersController.stream;
  Stream<List<Service>> get servicesStream => _servicesController.stream;

  // Initialize
  Future<void> init() async {
    // Load initial data
    await Future.wait([
      _loadBarbers(),
      _loadServices(),
    ]);

    // Listen for changes
    _listenToBarbers();
    _listenToServices();
  }

  // Load barbers
  Future<List<Barber>> _loadBarbers() async {
    try {
      final snapshot = await _firestore.collection('barbers').get();
      final barbers = snapshot.docs.map((doc) {
        return Barber.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      _barbersController.add(barbers);
      return barbers;
    } catch (e) {
      print('Error loading barbers: $e');
      return [];
    }
  }

  // Load services
  Future<List<Service>> _loadServices() async {
    try {
      final snapshot = await _firestore.collection('services').get();
      final services = snapshot.docs.map((doc) {
        return Service.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      _servicesController.add(services);
      return services;
    } catch (e) {
      print('Error loading services: $e');
      return [];
    }
  }

  // Listen to barbers
  void _listenToBarbers() {
    _firestore.collection('barbers').snapshots().listen((snapshot) {
      final barbers = snapshot.docs.map((doc) {
        return Barber.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      _barbersController.add(barbers);
    });
  }

  // Listen to services
  void _listenToServices() {
    _firestore.collection('services').snapshots().listen((snapshot) {
      final services = snapshot.docs.map((doc) {
        return Service.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();

      _servicesController.add(services);
    });
  }

  // Get all barbers
  Future<List<Barber>> getBarbers() async {
    try {
      final snapshot = await _firestore.collection('barbers').get();
      return snapshot.docs.map((doc) {
        return Barber.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting barbers: $e');
      return [];
    }
  }

  // Get barber by ID
  Future<Barber?> getBarberById(String id) async {
    try {
      final doc = await _firestore.collection('barbers').doc(id).get();
      if (!doc.exists) {
        return null;
      }

      return Barber.fromMap({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      print('Error getting barber by ID: $e');
      return null;
    }
  }

  // Get all services
  Future<List<Service>> getServices() async {
    try {
      final snapshot = await _firestore.collection('services').get();
      return snapshot.docs.map((doc) {
        return Service.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting services: $e');
      return [];
    }
  }

  // Get service by ID
  Future<Service?> getServiceById(String id) async {
    try {
      final doc = await _firestore.collection('services').doc(id).get();
      if (!doc.exists) {
        return null;
      }

      return Service.fromMap({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      print('Error getting service by ID: $e');
      return null;
    }
  }

  // Get promotion services
  Future<List<Service>> getPromotionServices() async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .where('isPromotion', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        return Service.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      print('Error getting promotion services: $e');
      return [];
    }
  }

  // Dispose
  void dispose() {
    _barbersController.close();
    _servicesController.close();
  }
}