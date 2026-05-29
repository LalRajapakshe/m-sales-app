class User {
  int? id;
  String username;
  String password;
  String? userId;


  User({this.id, required this.username, required this.password, this.userId,});

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'username': username,
      'password': password,
      'userId': userId,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Extract a User object from a Map object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      userId: map['userId'],
    );
  }
}