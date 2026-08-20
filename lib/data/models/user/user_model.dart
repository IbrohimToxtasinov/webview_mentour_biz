class UserModel {
  final String firstName;
  final String lastName;
  final String fullName;
  final String username;
  final String language;
  final String role;
  final String status;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.username,
    required this.language,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    firstName: json["firstName"] as String? ?? "",
    lastName: json["lastName"] as String? ?? "",
    fullName: json["fullName"] as String? ?? "",
    username: json["username"] as String? ?? "",
    language: json["language"] as String? ?? "",
    role: json["role"] as String? ?? "",
    status: json["status"] as String? ?? "",
  );
}
