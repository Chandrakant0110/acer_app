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

  // Create a User from a Firebase User
  factory User.fromFirebaseUser(dynamic firebaseUser) {
    return User(
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      imageUrl: firebaseUser.photoURL,
    );
  }

  // Convert to Map for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }

  // Create a User from Json (SharedPreferences)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}
