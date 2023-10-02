import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_screen/model/user.dart' as LocalUser;
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatelessWidget {
  Stream<LocalUser.User> _getUserDetails(String userID) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return _firestore
        .collection('users')
        .doc(userID)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;

      return LocalUser.User(
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        userID: '', // Replace with the appropriate value
        roles: '', // Replace with the appropriate value
        // Add other fields here
      );
    });
  }

  void _editField(
    BuildContext context,
    String fieldName,
    String currentValue,
    String field,
    String userID,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _textController = TextEditingController(text: currentValue);
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: TextFormField(
            controller: _textController,
            decoration: InputDecoration(labelText: 'New $fieldName'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final newValue = _textController.text;
                if (field == 'email' && newValue != currentValue) {
                  _updateEmail(context, newValue, userID);
                } else {
                  onSave(context, newValue, field, userID);
                }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onSave(
    BuildContext context,
    String newValue,
    String field,
    String userID,
  ) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    _firestore.collection('users').doc(userID).update({
      field: newValue,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $error')),
      );
    });
  }

  void _updateEmail(BuildContext context, String newEmail, String userID) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      firebaseUser.updateEmail(newEmail).then((_) {
        _firestore.collection('users').doc(userID).update({
          'email': newEmail,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email updated successfully')),
          );
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating email: $error')),
          );
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating email: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Add padding here
        child: Center(
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state.authState == AuthState.authenticated) {
                final user = state.user;

                return StreamBuilder<LocalUser.User>(
                  stream: _getUserDetails(user!.userID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final userDetails = snapshot.data;

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                              'assets/images/default_profile_image.png'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${userDetails?.firstName ?? ''} ${userDetails?.lastName ?? ''}',
                          style: TextStyle(color: Colors.black),
                        ),
                        SingleChildScrollView(
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(''),
                                numeric: false,
                              ),
                              DataColumn(
                                label: Text(''),
                                numeric: false,
                              ),
                              DataColumn(
                                label: Text(''),
                                numeric: false,
                              ),
                            ],
                            rows: [
                              _buildDataRow(
                                context,
                                'First Name',
                                userDetails?.firstName ?? '',
                                'firstName',
                                user.userID!,
                              ),
                              _buildDataRow(
                                context,
                                'Last Name',
                                userDetails?.lastName ?? '',
                                'lastName',
                                user.userID!,
                              ),
                              _buildDataRow(
                                context,
                                'Email',
                                userDetails?.email ?? '',
                                'email',
                                user.userID!,
                              ),
                              _buildPasswordRow(context),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return Text(
                  'Please log in to edit your profile.',
                  style: TextStyle(fontSize: 18),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    String attribute,
    String value,
    String field,
    String userID,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(attribute)),
        DataCell(Text(value)),
        DataCell(IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _editField(context, attribute, value, field, userID);
          },
        )),
      ],
    );
  }

  DataRow _buildPasswordRow(BuildContext context) {
    return DataRow(
      cells: [
        DataCell(Text('Password')),
        DataCell(Text('*********')),
        DataCell(IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _changePassword(context);
          },
        )),
      ],
    );
  }

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _passwordController = TextEditingController();
        return AlertDialog(
          title: Text('Change Password'),
          content: TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'New Password'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final newPassword = _passwordController.text;
                if (newPassword.isNotEmpty) {
                  _updatePassword(context, newPassword);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password cannot be empty')),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updatePassword(BuildContext context, String newPassword) {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      firebaseUser.updatePassword(newPassword).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating password: $error')),
        );
      });
    }
  }
}
