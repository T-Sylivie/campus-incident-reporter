import '../core/constants.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isStaff => role == Roles.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
        uid: uid,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? Roles.student,
      );
}