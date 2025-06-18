import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../models/barber.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import '../utils/whatsapp_launcher.dart';
import '../widgets/barber_selection.dart';

class AppointmentScreen extends StatefulWidget {
  final Service service;
  
  const AppointmentScreen({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  Barber? _selectedBarber;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: AppColors.primary,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: AppColors.primary,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedBarber != null) {
      // Criar objeto de agendamento
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        barber: _selectedBarber!,
        service: widget.service,
        dateTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        clientName: _nameController.text,
        clientPhone: _phoneController.text,
      );
      
      // Abrir WhatsApp com mensagem pré-definida
      WhatsAppLauncher.openWhatsApp(
        _selectedBarber!.whatsapp,
        appointment.whatsappMessage,
      ).then((_) {
        // Mostrar confirmação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento enviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Voltar para a tela anterior
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir WhatsApp: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else if (_selectedBarber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um barbeiro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Agendar Serviço',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalhes do serviço
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.content_cut,
                          color: AppColors.secondary,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.name,
                            style: AppTextStyles.subheading,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.service.description,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (widget.service.hasDiscount) ...[
                                Text(
                                  'R\$${widget.service.price.toStringAsFixed(2)}',
                                  style: AppTextStyles.priceDiscount,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'R\$${widget.service.discountPrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.price,
                                ),
                              ] else
                                Text(
                                  'R\$${widget.service.price.toStringAsFixed(2)}',
                                  style: AppTextStyles.price,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Seleção de barbeiro
              const Text(
                'Escolha seu barbeiro',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 16),
              BarberSelection(
                barbers: barbers,
                onSelected: (barber) {
                  setState(() {
                    _selectedBarber = barber;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Seleção de data e hora
              const Text(
                'Escolha a data e hora',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                                  style: AppTextStyles.body,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hora',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: AppTextStyles.body,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Formulário de contato
              const Text(
                'Seus dados',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person, color: AppColors.secondary),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                      ),
                      style: AppTextStyles.body,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone com DDD',
                        prefixIcon: Icon(Icons.phone, color: AppColors.secondary),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                      ),
                      style: AppTextStyles.body,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe seu telefone';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Botão de agendamento
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'AGENDAR VIA WHATSAPP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}