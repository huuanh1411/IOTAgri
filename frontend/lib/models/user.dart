class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'user' hoặc 'admin'

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'user', // Mặc định là 'user' nếu không truyền
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }

  // Helper getter để check role nhanh
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}