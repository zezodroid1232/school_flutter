class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'teacher' or 'student'
  final String? photoUrl;
  final bool isActive; // For students waiting for teacher approval
  final String? teacherId; // For students linked to a teacher

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.isActive = false,
    this.teacherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'teacherId': teacherId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      photoUrl: map['photoUrl'],
      isActive: map['isActive'] ?? false,
      teacherId: map['teacherId'],
    );
  }
}
