import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';
import 'firebase_service.dart';

class AppointmentService {
  // Singleton pattern
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  // Stream controller for appointment changes
  final _appointmentsController =
      StreamController<List<Appointment>>.broadcast();
  Stream<List<Appointment>> get appointmentsStream =>
      _appointmentsController.stream;

  // Get all appointments
  Future<List<Appointment>> getAppointments() async {
    try {
      final snapshot = await _firestore.collection('appointments').get();
      return _processAppointmentSnapshots(snapshot.docs);
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  // Get appointments for a specific user
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();
      return _processAppointmentSnapshots(snapshot.docs);
    } catch (e) {
      print('Error getting user appointments: $e');
      return [];
    }
  }

  // Listen to user appointments
  Stream<List<Appointment>> listenToUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) => _processAppointmentSnapshots(snapshot.docs));
  }

  // Process appointment snapshots
  Future<List<Appointment>> _processAppointmentSnapshots(
      List<QueryDocumentSnapshot> docs) async {
    final appointments = <Appointment>[];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Get barber data
      final barberDoc =
          await _firestore.collection('barbers').doc(data['barberId']).get();
      final barberData = barberDoc.data() as Map<String, dynamic>;
      final barber = Barber.fromMap({
        'id': barberDoc.id,
        ...barberData,
      });

      // Get service data
      final serviceDoc =
          await _firestore.collection('services').doc(data['serviceId']).get();
      final serviceData = serviceDoc.data() as Map<String, dynamic>;
      final service = Service.fromMap({
        'id': serviceDoc.id,
        ...serviceData,
      });

      // Create appointment
      final appointment = Appointment(
        id: doc.id,
        barber: barber,
        service: service,
        dateTime: (data['dateTime'] as Timestamp).toDate(),
        clientName: data['clientName'],
        clientPhone: data['clientPhone'],
        status: _parseAppointmentStatus(data['status']),
      );

      appointments.add(appointment);
    }

    return appointments;
  }

  // Create a new appointment
  Future<Appointment> createAppointment({
    required String userId,
    required Barber barber,
    required Service service,
    required DateTime dateTime,
    required String clientName,
    required String clientPhone,
  }) async {
    try {
      // Check if time slot is available
      final isAvailable = await isTimeSlotAvailable(barber, dateTime);
      if (!isAvailable) {
        throw Exception('Este horário não está mais disponível');
      }

      // Create appointment document
      final appointmentData = {
        'userId': userId,
        'barberId': barber.id,
        'serviceId': service.id,
        'dateTime': Timestamp.fromDate(dateTime),
        'clientName': clientName,
        'clientPhone': clientPhone,
        'status': AppointmentStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await _firestore.collection('appointments').add(appointmentData);

      // Create appointment object
      final appointment = Appointment(
        id: docRef.id,
        barber: barber,
        service: service,
        dateTime: dateTime,
        clientName: clientName,
        clientPhone: clientPhone,
        status: AppointmentStatus.pending,
      );

      // Notify listeners
      final appointments = await getAppointments();
      _appointmentsController.add(appointments);

      return appointment;
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }

  // Update appointment status
  Future<Appointment> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    try {
      // Update appointment document
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get updated appointment
      final doc =
          await _firestore.collection('appointments').doc(appointmentId).get();
      final data = doc.data() as Map<String, dynamic>;

      // Get barber data
      final barberDoc =
          await _firestore.collection('barbers').doc(data['barberId']).get();
      final barberData = barberDoc.data() as Map<String, dynamic>;
      final barber = Barber.fromMap({
        'id': barberDoc.id,
        ...barberData,
      });

      // Get service data
      final serviceDoc =
          await _firestore.collection('services').doc(data['serviceId']).get();
      final serviceData = serviceDoc.data() as Map<String, dynamic>;
      final service = Service.fromMap({
        'id': serviceDoc.id,
        ...serviceData,
      });

      // Create appointment
      final appointment = Appointment(
        id: doc.id,
        barber: barber,
        service: service,
        dateTime: (data['dateTime'] as Timestamp).toDate(),
        clientName: data['clientName'],
        clientPhone: data['clientPhone'],
        status: status,
      );

      // Notify listeners
      final appointments = await getAppointments();
      _appointmentsController.add(appointments);

      return appointment;
    } catch (e) {
      throw Exception('Erro ao atualizar status do agendamento: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
    } catch (e) {
      throw Exception('Erro ao cancelar agendamento: $e');
    }
  }

  // Check if time slot is available
  Future<bool> isTimeSlotAvailable(Barber barber, DateTime dateTime) async {
    try {
      final startOfHour = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
      );

      final endOfHour = startOfHour.add(const Duration(hours: 1));

      final snapshot = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barber.id)
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfHour))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfHour))
          .where('status', whereIn: [
        AppointmentStatus.pending.name,
        AppointmentStatus.confirmed.name,
      ]).get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking time slot availability: $e');
      return false;
    }
  }

  // Get available time slots for a specific day
  Future<List<DateTime>> getAvailableTimeSlots(
      Barber barber, DateTime date) async {
    try {
      final List<DateTime> availableSlots = [];

      // Business hours: 9 AM to 7 PM
      final startTime = DateTime(date.year, date.month, date.day, 9, 0);
      final endTime = DateTime(date.year, date.month, date.day, 19, 0);

      // Get all appointments for this barber on this day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: barber.id)
          .where('dateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: [
        AppointmentStatus.pending.name,
        AppointmentStatus.confirmed.name,
      ]).get();

      // Get booked time slots
      final bookedSlots = snapshot.docs.map((doc) {
        final data = doc.data();
        final dateTime = (data['dateTime'] as Timestamp).toDate();
        return DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
        );
      }).toList();

      // Check each hour
      var currentSlot = startTime;
      while (currentSlot.isBefore(endTime)) {
        final slotDateTime = DateTime(
          currentSlot.year,
          currentSlot.month,
          currentSlot.day,
          currentSlot.hour,
        );

        // Check if slot is not booked
        if (!bookedSlots.any((bookedSlot) =>
            bookedSlot.year == slotDateTime.year &&
            bookedSlot.month == slotDateTime.month &&
            bookedSlot.day == slotDateTime.day &&
            bookedSlot.hour == slotDateTime.hour)) {
          availableSlots.add(slotDateTime);
        }

        // Next hour
        currentSlot = currentSlot.add(const Duration(hours: 1));
      }

      return availableSlots;
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }

  // Helper method to parse appointment status
  AppointmentStatus _parseAppointmentStatus(String? statusStr) {
    if (statusStr == null) return AppointmentStatus.pending;

    try {
      // Remove the prefix if it exists
      final cleanStatus =
          statusStr.contains('.') ? statusStr.split('.').last : statusStr;

      return AppointmentStatus.values.firstWhere(
        (status) => status.name == cleanStatus,
        orElse: () => AppointmentStatus.pending,
      );
    } catch (e) {
      print('Error parsing appointment status: $e');
      return AppointmentStatus.pending;
    }
  }

  // Dispose
  void dispose() {
    _appointmentsController.close();
  }
}
