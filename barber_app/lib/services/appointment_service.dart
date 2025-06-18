import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';

class AppointmentService {
  // Singleton pattern
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  // Stream controller for appointment changes
  final _appointmentsController = StreamController<List<Appointment>>.broadcast();
  Stream<List<Appointment>> get appointmentsStream => _appointmentsController.stream;

  // Mock appointments for demo
  final List<Appointment> _appointments = [];

  // Get all appointments
  List<Appointment> getAppointments() {
    return List.from(_appointments);
  }

  // Get appointments for a specific user
  List<Appointment> getUserAppointments(String userId) {
    return _appointments.where((appointment) => 
      appointment.clientPhone == userId || 
      appointment.id.contains(userId)
    ).toList();
  }

  // Create a new appointment
  Future<Appointment> createAppointment({
    required Barber barber,
    required Service service,
    required DateTime dateTime,
    required String clientName,
    required String clientPhone,
  }) async {
    // Create appointment
    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      barber: barber,
      service: service,
      dateTime: dateTime,
      clientName: clientName,
      clientPhone: clientPhone,
      status: AppointmentStatus.pending,
    );
    
    // Add to list
    _appointments.add(appointment);
    
    // Save appointment ID to preferences
    final prefs = await SharedPreferences.getInstance();
    final appointmentIds = prefs.getStringList('appointmentIds') ?? [];
    appointmentIds.add(appointment.id);
    await prefs.setStringList('appointmentIds', appointmentIds);
    
    // Notify listeners
    _appointmentsController.add(List.from(_appointments));
    
    return appointment;
  }

  // Update appointment status
  Future<Appointment> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    final index = _appointments.indexWhere((appointment) => appointment.id == appointmentId);
    
    if (index == -1) {
      throw Exception('Agendamento não encontrado');
    }
    
    // Create updated appointment
    final updatedAppointment = Appointment(
      id: _appointments[index].id,
      barber: _appointments[index].barber,
      service: _appointments[index].service,
      dateTime: _appointments[index].dateTime,
      clientName: _appointments[index].clientName,
      clientPhone: _appointments[index].clientPhone,
      status: status,
    );
    
    // Update in list
    _appointments[index] = updatedAppointment;
    
    // Notify listeners
    _appointmentsController.add(List.from(_appointments));
    
    return updatedAppointment;
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((appointment) => appointment.id == appointmentId);
    
    if (index == -1) {
      throw Exception('Agendamento não encontrado');
    }
    
    // Update status to cancelled
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  // Check if time slot is available
  bool isTimeSlotAvailable(Barber barber, DateTime dateTime) {
    // Check if there's any appointment for this barber at the same time
    return !_appointments.any((appointment) => 
      appointment.barber.id == barber.id && 
      appointment.dateTime.year == dateTime.year &&
      appointment.dateTime.month == dateTime.month &&
      appointment.dateTime.day == dateTime.day &&
      appointment.dateTime.hour == dateTime.hour &&
      appointment.status != AppointmentStatus.cancelled
    );
  }

  // Get available time slots for a specific day
  List<DateTime> getAvailableTimeSlots(Barber barber, DateTime date) {
    // Business hours: 9 AM to 7 PM
    final List<DateTime> availableSlots = [];
    
    // Start time: 9 AM
    DateTime startTime = DateTime(
      date.year,
      date.month,
      date.day,
      9,
      0,
    );
    
    // End time: 7 PM
    final endTime = DateTime(
      date.year,
      date.month,
      date.day,
      19,
      0,
    );
    
    // Check each hour
    while (startTime.isBefore(endTime)) {
      if (isTimeSlotAvailable(barber, startTime)) {
        availableSlots.add(startTime);
      }
      
      // Next hour
      startTime = startTime.add(const Duration(hours: 1));
    }
    
    return availableSlots;
  }

  // Dispose
  void dispose() {
    _appointmentsController.close();
  }
}