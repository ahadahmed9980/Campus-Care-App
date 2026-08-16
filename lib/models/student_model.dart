class StudentModel {
  final String id;
  final String fullName;
  final String studentId;
  final String department;
  final String semester;
  final String email;
  final String phone;
  final String profilePicture;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.studentId,
    required this.department,
    required this.semester,
    required this.email,
    required this.phone,
    required this.profilePicture,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      studentId: map['studentId'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'studentId': studentId,
      'department': department,
      'semester': semester,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
    };
  }
}