import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/constants.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';

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
                        // Implement Edit Profile function
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          user.profilePictureURL == ''
                              ? CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey.shade400,
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: Image.asset(
                                        'assets/images/placeholder.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : displayCircleImage(
                                  user.profilePictureURL, 70, true),
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
                      // Implement Temperature function
                    },
                    child: Text('Temperature'),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement Water level function
                    },
                    child: Text('Water level'),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement Feed now function
                    },
                    child: Text('Feed now'),
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement Display feeding time function
                    },
                    child: Text('Display feeding time'),
                    style: ElevatedButton.styleFrom(primary: Colors.brown),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement pH level function
                    },
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
