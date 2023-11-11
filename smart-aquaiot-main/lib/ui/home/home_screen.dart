import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';
import 'package:flutter_login_screen/ui/home/feed_now_page.dart';
import 'edit_profile_page.dart';
import 'temperature_page.dart';
import 'water_level_page.dart';
import 'display_feeding_time_page.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? profilePicURL; // Store the profile picture URL
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    profilePicURL = widget
        .user.profilePicURL; // Initialize with the user's profile picture URL
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
            style: TextStyle(
              color: isDarkMode(context)
                  ? Colors.grey.shade50
                  : Colors.grey.shade900,
            ),
          ),
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
            color: isDarkMode(context)
                ? Colors.grey.shade50
                : Colors.grey.shade900,
          ),
          backgroundColor:
              isDarkMode(context) ? Colors.grey.shade900 : Colors.grey.shade50,
          centerTitle: true,
        ),
        body: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.userID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data?.data() as Map<String, dynamic>;
                  final profilePicURL = data['profilePicURL'];
                  if (profilePicURL == null || profilePicURL.isEmpty) {
                    return Container(
                      margin: EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4.0,
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Please upload your profile picture at EDIT PROFILE button !',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }
                return Container();
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to EditProfilePage
                          final updatedUser = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                profilePicURL:
                                    profilePicURL, // Pass the profilePicURL
                                firstName: widget.user.firstName,
                                lastName: widget.user.lastName,
                                onUpdateProfilePicURL:
                                    _updateProfilePicURL, // Pass the callback
                              ),
                            ),
                          );

                          if (updatedUser != null) {
                            // Update the user object with new details
                            setState(() {
                              profilePicURL = updatedUser.profilePicURL;
                              widget.user.firstName = updatedUser.firstName;
                              widget.user.lastName = updatedUser.lastName;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: profilePicURL != null
                                  ? NetworkImage(profilePicURL!)
                                  : _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                          as ImageProvider<Object>?
                                      : AssetImage(
                                              'assets/images/default_profile_image.png')
                                          as ImageProvider<Object>?,
                              key: UniqueKey(),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${widget.user.firstName} ${widget.user.lastName}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(35.0),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height:
                              80, // Increase the height to make the button taller
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TemperaturePage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/temperature.png',
                              height: 50,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height:
                              80, // Increase the height to make the button taller
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WaterLevelPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/water_level.png',
                              height: 50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Added gap
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 80,
                          child: ElevatedButton(
                           onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedNowPage(), // Replace with the actual name of your feed_now_page.dart
                ),
              );
            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('FEED NOW'),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height:
                              80, // Increase the height to make the button taller
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DisplayFeedingTimePage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('FEEDING TIME'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Added gap
                  SizedBox(
                    height: 80, // Increase the height to make the button taller
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthenticationBloc>().add(LogoutEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('LOG OUT',
                          style: TextStyle(
                            fontSize: 24.0,
                            color: Color.fromARGB(255, 201, 5, 5),
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfilePicURL(String newProfilePicURL) {
    setState(() {
      profilePicURL = newProfilePicURL;
    });
  }
}
