class Appointment {
  final int? id;
  final int userId;
  final String doctorName;
  final String appointmentDate;
  final String appointmentTime;
  final String? patientName;
  final String? reason;
  final String? createdAt;

  Appointment({
    this.id,
    required this.userId,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    this.patientName,
    this.reason,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'doctor_name': doctorName,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'patient_name': patientName,
      'reason': reason,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      doctorName: map['doctor_name'] as String,
      appointmentDate: map['appointment_date'] as String,
      appointmentTime: map['appointment_time'] as String,
      patientName: map['patient_name'] as String?,
      reason: map['reason'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
