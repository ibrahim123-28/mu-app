class UserModel {
  final String uid;
  final String name;
  final String email;
  final String course;
  final String semester;
  
  // Naye variables
  final String role;
  final String? batchId; 

  // Constructor (Yahan initialize hota hai)
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.course,
    required this.semester,
    required this.role,
    this.batchId,
  });

  // Firestore se data read karne ke liye
  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      uid: documentId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      course: json['course'] ?? '',
      semester: json['semester'] ?? '',
      role: json['role'] ?? 'student', // Default role student
      batchId: json['batch_id'],
    );
  }

  // Firestore me data save karne ke liye
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'course': course,
      'semester': semester,
      'role': role,
      'batch_id': batchId,
    };
  }
}