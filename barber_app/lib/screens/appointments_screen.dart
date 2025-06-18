import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/whatsapp_launcher.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _appointmentService = AppointmentService();
  final _user = AuthService().currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Appointment>> _getFilteredAppointments(
      AppointmentStatus status) async {
    if (_user == null) return [];

    final appointments =
        await _appointmentService.getUserAppointments(_user!.phoneNumber);

    if (status == AppointmentStatus.pending) {
      return appointments
          .where((a) =>
              a.status == AppointmentStatus.pending ||
              a.status == AppointmentStatus.confirmed)
          .toList();
    }

    return appointments.where((a) => a.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Meus Agendamentos'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Próximos'),
            Tab(text: 'Concluídos'),
            Tab(text: 'Cancelados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Próximos agendamentos
          _buildAppointmentList(AppointmentStatus.pending),

          // Agendamentos concluídos
          _buildAppointmentList(AppointmentStatus.completed),

          // Agendamentos cancelados
          _buildAppointmentList(AppointmentStatus.cancelled),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.primary),
        onPressed: () {
          // Navegar para a tela inicial para criar um novo agendamento
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildAppointmentList(AppointmentStatus status) {
    return FutureBuilder<List<Appointment>>(
      future: _getFilteredAppointments(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == AppointmentStatus.pending
                      ? Icons.calendar_today
                      : status == AppointmentStatus.completed
                          ? Icons.check_circle
                          : Icons.cancel,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  status == AppointmentStatus.pending
                      ? 'Nenhum agendamento próximo'
                      : status == AppointmentStatus.completed
                          ? 'Nenhum agendamento concluído'
                          : 'Nenhum agendamento cancelado',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                if (status == AppointmentStatus.pending)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      // Navegar para a tela inicial para criar um novo agendamento
                      Navigator.of(context).pop();
                    },
                    child: const Text('AGENDAR AGORA'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return _buildAppointmentCard(appointment);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isPending = appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.confirmed;
    final isCompleted = appointment.status == AppointmentStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: isPending
              ? AppColors.secondary.withAlpha(100)
              : isCompleted
                  ? Colors.green.withAlpha(100)
                  : Colors.red.withAlpha(100),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isPending
                  ? AppColors.secondary.withAlpha(30)
                  : isCompleted
                      ? Colors.green.withAlpha(30)
                      : Colors.red.withAlpha(30),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borderRadius - 1),
                topRight: Radius.circular(AppSizes.borderRadius - 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPending
                      ? Icons.calendar_today
                      : isCompleted
                          ? Icons.check_circle
                          : Icons.cancel,
                  color: isPending
                      ? AppColors.secondary
                      : isCompleted
                          ? Colors.green
                          : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.service.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Barbeiro: ${appointment.barber.name}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending
                        ? AppColors.secondary
                        : isCompleted
                            ? Colors.green
                            : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending
                        ? 'AGENDADO'
                        : isCompleted
                            ? 'CONCLUÍDO'
                            : 'CANCELADO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: [
                // Date and time
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(appointment.dateTime)} às ${DateFormat('HH:mm').format(appointment.dateTime)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.service.hasDiscount
                          ? 'R\$${appointment.service.discountPrice.toStringAsFixed(2)}'
                          : 'R\$${appointment.service.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (appointment.service.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        'R\$${appointment.service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                // Actions
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Reschedule button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.secondary),
                          ),
                          onPressed: () {
                            // Implement reschedule
                          },
                          child: const Text('REAGENDAR'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Contact button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: () {
                            WhatsAppLauncher.openWhatsApp(
                              appointment.barber.whatsapp,
                              'Olá! Gostaria de confirmar meu agendamento para ${appointment.service.name} no dia ${appointment.formattedDate} às ${appointment.formattedTime}.',
                            );
                          },
                          child: const Text('CONTATAR'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () {
                        // Implement cancel
                        _showCancelDialog(appointment);
                      },
                      child: const Text('CANCELAR AGENDAMENTO'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Cancelar Agendamento',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento? Esta ação não pode ser desfeita.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'NÃO',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();

              // Cancel appointment
              await _appointmentService.cancelAppointment(appointment.id);

              // Refresh UI
              setState(() {});
            },
            child: const Text('SIM, CANCELAR'),
          ),
        ],
      ),
    );
  }
}
