import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/appointment.dart';
import '../services/auth_service.dart';
import '../widgets/appointment_card.dart';
import 'booking_screen.dart';
import 'edit_appointment_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper _dbHelper = DBHelper();
  final AuthService _authService = AuthService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final appointments = await _dbHelper.getAppointments(widget.userId);
    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });
  }

  Future<void> _deleteAppointment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteAppointment(id);
      _loadAppointments();
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(
                  child: Text(
                    'No appointments yet.\nTap + to book one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return AppointmentCard(
                      appointment: appointment,
                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditAppointmentScreen(
                              appointment: appointment,
                            ),
                          ),
                        );
                        _loadAppointments();
                      },
                      onDelete: () => _deleteAppointment(appointment.id!),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingScreen(userId: widget.userId),
            ),
          );
          _loadAppointments();
        },
        tooltip: 'Book Appointment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
