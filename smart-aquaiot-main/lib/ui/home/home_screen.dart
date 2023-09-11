import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/constants.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';
import 'package:flutter_login_screen/ui/home/ph_level_page.dart';
import 'edit_profile_page.dart';
import 'temperature_page.dart'; // Import the temperature page file
import 'water_level_page.dart'; // Import the water level page file
import 'feed_now_page.dart'; // Import the feed now page file
import 'display_feeding_time_page.dart'; // Import the display feeding time page file

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;

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
            SizedBox(
              height: 160, // Set the height for the 'Edit Profile' button
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Edit Profile Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        elevation: 8, // Increase elevation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0, // Increase vertical padding
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columns for symmetry
                childAspectRatio: 1.0, // Square aspect ratio
                padding: EdgeInsets.all(16.0),
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Temperature Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TemperaturePage()),
                      );
                    },
                    child: Text('Temperature'),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Water Level Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WaterLevelPage()),
                      );
                    },
                    child: Text('Water level'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Feed Now Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedNowPage()),
                      );
                    },
                    child: Text('Feed now'),
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Display Feeding Time Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayFeedingTimePage()),
                      );
                    },
                    child: Text('Display feeding time'),
                    style: ElevatedButton.styleFrom(primary: Colors.brown),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to pH Level Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => pHLevelPage()),
                      );
                    }, // Add a closing parenthesis here
                    child: Text('pH level'),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement Logout function
                      context.read<AuthenticationBloc>().add(LogoutEvent());
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.purple),
                    child: Text('Logout', style: TextStyle(fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
