enum UserRole { customer, rider }

/// User model for the app
class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
  });

  // Dummy user data
  static User getDummyUser({UserRole role = UserRole.customer}) {
    return User(
      id: '1',
      name: 'John Doe',
      phone: '+91 9876543210',
      email: 'john.doe@example.com',
      avatarUrl: null,
      role: role,
    );
  }
}
