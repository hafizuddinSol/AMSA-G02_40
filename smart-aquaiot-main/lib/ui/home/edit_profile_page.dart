import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_screen/model/user.dart' as LocalUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_screen/ui/auth/login/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final String? profilePicURL;
  final String? firstName;
  final String? lastName;
  final Function(String)? onUpdateProfilePicURL; // Callback function

  EditProfilePage({
    this.profilePicURL,
    this.firstName,
    this.lastName,
    this.onUpdateProfilePicURL, // Pass the callback function
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _selectedImage;
  String? _profilePicURL;

  @override
  void initState() {
    super.initState();
    _loadProfilePicURL();
  }

  Future<void> _loadProfilePicURL() async {
    final user = BlocProvider.of<AuthenticationBloc>(context).state.user!;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.userID)
        .get();

    setState(() {
      _profilePicURL = snapshot.data()?['profilePicURL'];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });

      final user = BlocProvider.of<AuthenticationBloc>(context).state.user!;
      final imageURL = await _uploadProfilePicture(user.userID);

      if (imageURL != null) {
        setState(() {
          _profilePicURL = imageURL;
        });

        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
        await _firestore.collection('users').doc(user.userID).update({
          'profilePicURL': imageURL,
        });

        // Call the callback to update the profile picture URL in HomeScreen
        if (widget.onUpdateProfilePicURL != null) {
          widget.onUpdateProfilePicURL!(imageURL);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated successfully')),
        );

        // Add this code to sign out the user
        // FirebaseAuth.instance.signOut();

        // You can also navigate to the login page if needed
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
      );
    });
  }

  Future<String?> _uploadProfilePicture(String userID) async {
    if (_selectedImage == null) {
      return null;
    }

    final storage = FirebaseStorage.instance;
    final date = DateTime.now().toLocal();
    final formattedDate = date
        .toLocal()
        .toString()
        .substring(0, 19)
        .replaceAll(' ', '_')
        .replaceAll(':', '-');
    final ref =
        storage.ref().child('users/$userID/profilePic/$formattedDate.jpg');

    try {
      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
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

                    final profilePicURL = userDetails?.profilePicURL;

                    return Column(
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: AlertDialog(
                                        title: Text('Choose Image Source'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(Icons.photo),
                                              title:
                                                  Text('Choose from Gallery'),
                                              onTap: () {
                                                _pickImage(ImageSource.gallery);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.camera),
                                              title: Text('Take a Photo'),
                                              onTap: () {
                                                _pickImage(ImageSource.camera);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: _profilePicURL != null
                                    ? NetworkImage(_profilePicURL!)
                                    : _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                            as ImageProvider<Object>?
                                        : AssetImage(
                                                'assets/images/default_profile_image.png')
                                            as ImageProvider<Object>?,
                                key: UniqueKey(),
                              ),
                            ),
                            Text(
                              '${userDetails?.firstName ?? ''} ${userDetails?.lastName ?? ''}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showImagePickerDialog();
                              },
                              child: Text('Edit'),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
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
                                user.userID,
                              ),
                              _buildDataRow(
                                context,
                                'Last Name',
                                userDetails?.lastName ?? '',
                                'lastName',
                                user.userID,
                              ),
                              _buildDataRow(
                                context,
                                'Email',
                                userDetails?.email ?? '',
                                'email',
                                user.userID,
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
            validator: (value) {
              if (fieldName == 'First Name' || fieldName == 'Last Name') {
                if (RegExp(r'[0-9]').hasMatch(value!)) {
                  return 'Name should not contain numbers';
                }
              }
              return null;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                final newValue = _textController.text;
                if (newValue.isNotEmpty) {
                  if (fieldName == 'First Name' || fieldName == 'Last Name') {
                    if (RegExp(r'[0-9]').hasMatch(newValue)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('$fieldName should not contain numbers')),
                      );
                      return; // Do not save if numbers are present
                    }
                  }
                  if (field == 'email' && newValue != currentValue) {
                    _updateEmail(context, newValue, userID);
                  } else {
                    onSave(context, newValue, field, userID);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$fieldName cannot be empty')),
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

  void _updateEmail(BuildContext context, String newEmail, String userID) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final User? firebaseUser = _auth.currentUser;
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
        SnackBar(
            content: Text(
                'Profile updated successfully, Please Log In again to see new Updated Info')),
      );
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $error')),
      );
    });
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
}
