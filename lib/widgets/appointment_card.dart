import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          appointment.doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Date: ${appointment.appointmentDate}'),
            Text('Time: ${appointment.appointmentTime}'),
            if (appointment.reason != null && appointment.reason!.isNotEmpty)
              Text('Reason: ${appointment.reason}'),
            if (appointment.patientName != null &&
                appointment.patientName!.isNotEmpty)
              Text('Patient: ${appointment.patientName}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
