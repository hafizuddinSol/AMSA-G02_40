import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/model/user.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_screen.dart';
import 'package:flutter_login_screen/ui/home/ph_level_page.dart';
import 'edit_profile_page.dart';
import 'temperature_page.dart';
import 'water_level_page.dart';
import 'feed_now_page.dart';
import 'display_feeding_time_page.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<String> fetchTemperatureData() async {
    // Replace this with your logic to fetch temperature data
    await Future.delayed(Duration(seconds: 2));
    return '25°C';
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
              height: 160,
              child: FutureBuilder<String>(
                future: fetchTemperatureData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ElevatedButton(
                      onPressed: () {
                        // Navigate to Edit Profile Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 17.0,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Text(
                                'EDIT PROFILE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 4.7,
                padding: EdgeInsets.all(15.0),
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 17.0,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TemperaturePage()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/temperature.png',
                      height: 50,
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WaterLevelPage()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/water_level.png',
                      height: 50,
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedNowPage()),
                      );
                    },
                    child: Text(
                      'FEED NOW',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayFeedingTimePage()),
                      );
                    },
                    child: Text(
                      'DISPLAY FEEDING TIME',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => pHLevelPage()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/ph_level.png',
                      height: 50,
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(LogoutEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                      elevation: 8,
                      side: BorderSide(color: Colors.red, width: 2),
                    ),
                    child: Text('LOG OUT',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Color.fromARGB(255, 201, 5, 5),
                          fontWeight: FontWeight.w900,
                        )),
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
