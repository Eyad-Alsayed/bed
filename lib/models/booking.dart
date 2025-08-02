class Booking {
  final int? id;
  final String patientMrn;
  final String procedure;
  final String urgency;
  final String consultantName;
  final String consultantPhone;
  final String physicianName;
  final String physicianPhone;
  final String anesthesiaManagerName;
  final String anesthesiaManagerPhone;
  final String anesthesiaConsultantName;
  final String anesthesiaConsultantPhone;
  final DateTime bookingTime;
  final String bookingStatus;

  Booking({
    this.id,
    required this.patientMrn,
    required this.procedure,
    required this.urgency,
    required this.consultantName,
    required this.consultantPhone,
    required this.physicianName,
    required this.physicianPhone,
    required this.anesthesiaManagerName,
    required this.anesthesiaManagerPhone,
    required this.anesthesiaConsultantName,
    required this.anesthesiaConsultantPhone,
    required this.bookingTime,
    this.bookingStatus = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientMrn': patientMrn,
      'procedure': procedure,
      'urgency': urgency,
      'consultantName': consultantName,
      'consultantPhone': consultantPhone,
      'physicianName': physicianName,
      'physicianPhone': physicianPhone,
      'anesthesiaManagerName': anesthesiaManagerName,
      'anesthesiaManagerPhone': anesthesiaManagerPhone,
      'anesthesiaConsultantName': anesthesiaConsultantName,
      'anesthesiaConsultantPhone': anesthesiaConsultantPhone,
      'bookingTime': bookingTime.toIso8601String(),
      'bookingStatus': bookingStatus,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      patientMrn: map['patientMrn'],
      procedure: map['procedure'],
      urgency: map['urgency'],
      consultantName: map['consultantName'],
      consultantPhone: map['consultantPhone'],
      physicianName: map['physicianName'],
      physicianPhone: map['physicianPhone'],
      anesthesiaManagerName: map['anesthesiaManagerName'],
      anesthesiaManagerPhone: map['anesthesiaManagerPhone'],
      anesthesiaConsultantName: map['anesthesiaConsultantName'],
      anesthesiaConsultantPhone: map['anesthesiaConsultantPhone'],
      bookingTime: DateTime.parse(map['bookingTime']),
      bookingStatus: map['bookingStatus'],
    );
  }
}
