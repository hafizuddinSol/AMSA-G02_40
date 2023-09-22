class User {
  String email;
  String firstName;
  String lastName;
  String userID;
  String roles; // Make roles a required parameter

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userID,
    required this.roles, // Make roles a required parameter
  });


  String fullName() => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'] ?? '',
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      roles: parsedJson['roles'] ?? '', // Update to correctly parse roles
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'id': userID,
      'roles': roles,
    };
  }
}
