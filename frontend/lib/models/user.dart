// lib/models/user.dart
class User {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'admin' or 'user'
  final String plan;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.plan,
  });

  bool get isAdmin => role == 'admin';

  // Convert to map for persistence
  Map<String, String> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'role': role,
        'plan': plan,
      };

  static User fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        role: map['role'] as String,
        plan: map['plan'] as String,
      );
}