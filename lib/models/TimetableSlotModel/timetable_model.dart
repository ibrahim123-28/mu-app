class TimetableSlotModel {
  final String id;
  final String batchId;     // e.g., "fy_cs_2026"
  final String roomId;      // e.g., "lab_01"
  final String teacherName; // e.g., "Omkar Sir"
  final String subjectName; // e.g., "Python"
  final String dayOfWeek;   // e.g., "Monday"
  final String startTime;   // e.g., "10:00 AM"
  final String endTime;     // e.g., "12:00 PM"
  final String type;        // e.g., "Lab" or "Lecture"

  TimetableSlotModel({
    required this.id,
    required this.batchId,
    required this.roomId,
    required this.teacherName,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  // Firebase se data read karne ke liye
  factory TimetableSlotModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TimetableSlotModel(
      id: documentId,
      batchId: json['batch_id'] ?? '',
      roomId: json['room_id'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      type: json['type'] ?? 'Lecture',
    );
  }

  // Firebase me data save karne ke liye
  Map<String, dynamic> toJson() {
    return {
      'batch_id': batchId,
      'room_id': roomId,
      'teacher_name': teacherName,
      'subject_name': subjectName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'type': type,
    };
  }
}