import 'barber.dart';
import 'service.dart';

class Appointment {
  final String id;
  final Barber barber;
  final Service service;
  final DateTime dateTime;
  final String clientName;
  final String clientPhone;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.barber,
    required this.service,
    required this.dateTime,
    required this.clientName,
    required this.clientPhone,
    this.status = AppointmentStatus.pending,
  });

  String get formattedDate {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get whatsappMessage {
    return 'Olá! Gostaria de agendar um(a) ${service.name} com o barbeiro ${barber.name} para o dia ${formattedDate} às ${formattedTime}. Meu nome é $clientName.';
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled
}