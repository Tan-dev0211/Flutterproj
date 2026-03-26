import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/appointment.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentScreen({super.key, required this.appointment});

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _doctorController;
  late TextEditingController _patientController;
  late TextEditingController _reasonController;
  final _dbHelper = DBHelper();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _doctorController =
        TextEditingController(text: widget.appointment.doctorName);
    _patientController =
        TextEditingController(text: widget.appointment.patientName ?? '');
    _reasonController =
        TextEditingController(text: widget.appointment.reason ?? '');

    // Parse existing date
    try {
      _selectedDate =
          DateFormat('yyyy-MM-dd').parse(widget.appointment.appointmentDate);
    } catch (_) {}

    // Parse existing time
    try {
      final parts = widget.appointment.appointmentTime.split(':');
      if (parts.length >= 2) {
        // Handle "HH:MM AM/PM" or "HH:MM" formats
        final timeStr = widget.appointment.appointmentTime;
        final isPM = timeStr.toUpperCase().contains('PM');
        final isAM = timeStr.toUpperCase().contains('AM');
        int hour = int.parse(parts[0]);
        int minute =
            int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));

        if (isPM && hour != 12) hour += 12;
        if (isAM && hour == 12) hour = 0;

        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _patientController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _updateAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = Appointment(
      id: widget.appointment.id,
      userId: widget.appointment.userId,
      doctorName: _doctorController.text.trim(),
      appointmentDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      appointmentTime: _selectedTime!.format(context),
      patientName: _patientController.text.trim().isEmpty
          ? null
          : _patientController.text.trim(),
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      createdAt: widget.appointment.createdAt,
    );

    await _dbHelper.updateAppointment(updated);

    setState(() => _isSaving = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter doctor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                      : 'Select Date',
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.access_time),
                title: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Select Time',
                ),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _updateAppointment,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
