class User {
  String email;
  String firstName;
  String lastName;
  String userID;
  String roles;
  String verifyemailstatus;
  String? profilePicURL;

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userID,
    required this.roles, // Make roles a required parameter
    this.verifyemailstatus = 'false',
    this.profilePicURL, // Add this field
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
      profilePicURL: parsedJson['profilePicURL'], // Add profilePicURL
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
      'profilePicURL': profilePicURL, // Include profilePicURL in JSON
    };
  }
}
