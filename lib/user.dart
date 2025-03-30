class User {
  final String name;
  final String email;
  final String phone;
  final String? imageUrl;

  User({
    required this.name,
    required this.email,
    required this.phone,
    this.imageUrl,
  });
}
