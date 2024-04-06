class User {
  final int? id;
  final String photoUrl;
  final String firstName;
  final String lastName;
  final String matricula;
  final String password;

  User({
    required this.photoUrl,
    required this.firstName,
    required this.lastName,
    required this.matricula,
     this.id,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      photoUrl: map['photoUrl'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      matricula: map['matricula'],
      id: map['id'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoUrl': photoUrl,
      'firstName': firstName,
      'lastName': lastName,
      'matricula': matricula,
      'id': id,
      'password': password,
    };
  }
}

