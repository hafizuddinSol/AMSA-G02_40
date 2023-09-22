class User {
  String email;
  String firstName;
  String lastName;
  String userID;
  String roles; // Make roles a required parameter
  String verifyemailstatus; // Add this field

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userID,
    this.roles = 'user', 
    this.verifyemailstatus = 'false', 
  });


  String fullName() => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'] ?? '',
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      roles: parsedJson['roles'] ?? 'user',
      verifyemailstatus: parsedJson['verifyemailstatus'] ?? 'false', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'id': userID,
      'roles': roles,
      'verifyemailstatus': verifyemailstatus,
    };
  }
}
