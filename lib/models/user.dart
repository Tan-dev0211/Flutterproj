class User {
  final int? id;
  final String email;
  final String password;

  User({this.id, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}
