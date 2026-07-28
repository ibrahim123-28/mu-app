class BatchModel {
  final String id;
  final String batchName; // e.g., "FY B.Sc CS"
  final String joinCode;  // e.g., "FYCS26" (Yeh code daal kar student join karega)
  final String semester;  // e.g., "Sem 1"
  final bool isActive;

  BatchModel({
    required this.id,
    required this.batchName,
    required this.joinCode,
    required this.semester,
    this.isActive = true,
  });

  // Firebase se data read karne ke liye
  factory BatchModel.fromJson(Map<String, dynamic> json, String documentId) {
    return BatchModel(
      id: documentId,
      batchName: json['batch_name'] ?? '',
      joinCode: json['join_code'] ?? '',
      semester: json['semester'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  // Firebase me data save karne ke liye
  Map<String, dynamic> toJson() {
    return {
      'batch_name': batchName,
      'join_code': joinCode,
      'semester': semester,
      'is_active': isActive,
    };
  }
}