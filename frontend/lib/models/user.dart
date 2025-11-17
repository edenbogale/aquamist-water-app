class User {
  final String name;
  final String phone;
  final String email;
  final String address;

  User(
      {required this.name,
      required this.phone,
      required this.email,
      required this.address});

  User copyWith({String? name, String? phone, String? email, String? address}) {
    return User(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
