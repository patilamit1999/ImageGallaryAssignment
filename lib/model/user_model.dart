class User {
  final String password;

  User({
    required this.password,
  });

  User.fromMap(Map<dynamic, dynamic> res) : password = res['password'];

  Map<String, Object?> toMap(){
    return {
      'password' : password,
    };
  }
}
