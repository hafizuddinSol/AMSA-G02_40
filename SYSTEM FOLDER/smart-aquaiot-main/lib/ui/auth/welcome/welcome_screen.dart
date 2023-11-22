import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/services/helper.dart';
import 'package:flutter_login_screen/ui/auth/login/login_screen.dart';
import 'package:flutter_login_screen/ui/auth/signUp/sign_up_screen.dart';
import 'package:flutter_login_screen/ui/auth/welcome/welcome_bloc.dart';
import 'package:flutter_login_screen/ui/auth/login/login_admin.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle whiteTextStyle = TextStyle(
      fontSize: 18,
      color: Colors.white, // Set the text color to white
    );

    return BlocProvider<WelcomeBloc>(
      create: (context) => WelcomeBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                // Background Image
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                BlocListener<WelcomeBloc, WelcomeInitial>(
                  listener: (context, state) {
                    switch (state.pressTarget) {
                      case WelcomePressTarget.login:
                        push(context, const LoginScreen());
                        break;
                      case WelcomePressTarget.signup:
                        push(context, const SignUpScreen());
                        break;
                      case WelcomePressTarget.adminLogin:
                        push(context, const AdminLoginScreen());
                        break;
                      default:
                        break;
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          'assets/images/aquarium.png',
                          width: 150.0,
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 16, top: 32, right: 16, bottom: 8),
                        child: Text(
                          'Welcome to your AquaManager app!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 162, 217, 253),
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        child: Text(
                          'Your all-in-one aquarium management app.',
                          style:
                              whiteTextStyle, // Use the defined whiteTextStyle
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 40.0, left: 40.0, top: 40),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromWidth(
                                MediaQuery.of(context).size.width / 1.5),
                            backgroundColor: Color.fromARGB(255, 11, 156, 149),
                            textStyle: const TextStyle(color: Colors.white),
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 11, 156, 149),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            context.read<WelcomeBloc>().add(LoginPressed());
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 40.0, left: 40.0, top: 20, bottom: 20),
                        child: TextButton(
                          onPressed: () {
                            context.read<WelcomeBloc>().add(SignupPressed());
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            fixedSize: Size.fromWidth(
                                MediaQuery.of(context).size.width / 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 11, 156, 149),
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 11, 156, 149),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
