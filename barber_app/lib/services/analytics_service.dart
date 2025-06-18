import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';

class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Event types
  static const String eventAppOpen = 'app_open';
  static const String eventLogin = 'login';
  static const String eventSignup = 'signup';
  static const String eventViewService = 'view_service';
  static const String eventViewBarber = 'view_barber';
  static const String eventCreateAppointment = 'create_appointment';
  static const String eventCancelAppointment = 'cancel_appointment';
  static const String eventRateBarber = 'rate_barber';
  static const String eventShare = 'share';
  static const String eventError = 'error';

  // User properties
  Map<String, dynamic> _userProperties = {};

  // Initialize analytics
  Future<void> init() async {
    await _loadUserProperties();
    await _trackEvent(eventAppOpen);
  }

  // Track event
  Future<void> trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    await _trackEvent(eventName, parameters: parameters);
  }

  // Track login event
  Future<void> trackLogin(String method) async {
    await _trackEvent(eventLogin, parameters: {'method': method});
  }

  // Track signup event
  Future<void> trackSignup(String method) async {
    await _trackEvent(eventSignup, parameters: {'method': method});
  }

  // Track view service event
  Future<void> trackViewService(Service service) async {
    await _trackEvent(eventViewService, parameters: {
      'service_id': service.id,
      'service_name': service.name,
      'service_price': service.price,
    });
  }

  // Track view barber event
  Future<void> trackViewBarber(Barber barber) async {
    await _trackEvent(eventViewBarber, parameters: {
      'barber_id': barber.id,
      'barber_name': barber.name,
    });
  }

  // Track create appointment event
  Future<void> trackCreateAppointment(Appointment appointment) async {
    await _trackEvent(eventCreateAppointment, parameters: {
      'appointment_id': appointment.id,
      'barber_id': appointment.barber.id,
      'barber_name': appointment.barber.name,
      'service_id': appointment.service.id,
      'service_name': appointment.service.name,
      'service_price': appointment.service.hasDiscount
          ? appointment.service.discountPrice
          : appointment.service.price,
      'date': appointment.dateTime.toIso8601String(),
    });
  }

  // Track cancel appointment event
  Future<void> trackCancelAppointment(Appointment appointment) async {
    await _trackEvent(eventCancelAppointment, parameters: {
      'appointment_id': appointment.id,
      'barber_id': appointment.barber.id,
      'barber_name': appointment.barber.name,
      'service_id': appointment.service.id,
      'service_name': appointment.service.name,
      'date': appointment.dateTime.toIso8601String(),
    });
  }

  // Track rate barber event
  Future<void> trackRateBarber(Barber barber, double rating) async {
    await _trackEvent(eventRateBarber, parameters: {
      'barber_id': barber.id,
      'barber_name': barber.name,
      'rating': rating,
    });
  }

  // Track share event
  Future<void> trackShare(String contentType, String contentId) async {
    await _trackEvent(eventShare, parameters: {
      'content_type': contentType,
      'content_id': contentId,
    });
  }

  // Track error event
  Future<void> trackError(String errorMessage, String errorLocation) async {
    await _trackEvent(eventError, parameters: {
      'error_message': errorMessage,
      'error_location': errorLocation,
    });
  }

  // Set user property
  Future<void> setUserProperty(String name, dynamic value) async {
    _userProperties[name] = value;
    await _saveUserProperties();
  }

  // Get user property
  dynamic getUserProperty(String name) {
    return _userProperties[name];
  }

  // Clear user properties
  Future<void> clearUserProperties() async {
    _userProperties = {};
    await _saveUserProperties();
  }

  // Private methods
  Future<void> _trackEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // In a real app, this would send the event to a real analytics service
    // For now, we'll just print it to the console
    print('Analytics Event: $eventName');
    if (parameters != null) {
      print('Parameters: $parameters');
    }

    // Store event in local storage for later analysis
    final prefs = await SharedPreferences.getInstance();
    final events = prefs.getStringList('analytics_events') ?? [];
    
    final eventJson = {
      'name': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'parameters': parameters,
    }.toString();
    
    events.add(eventJson);
    
    // Keep only the last 100 events
    if (events.length > 100) {
      events.removeAt(0);
    }
    
    await prefs.setStringList('analytics_events', events);
  }

  Future<void> _loadUserProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final userPropertiesString = prefs.getString('user_properties');
    
    if (userPropertiesString != null) {
      _userProperties = Map<String, dynamic>.from({
        // Parse the string back to a map
        // In a real app, you would use json.decode
        // For simplicity, we're just using an empty map here
      });
    }
  }

  Future<void> _saveUserProperties() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_properties', _userProperties.toString());
  }
}