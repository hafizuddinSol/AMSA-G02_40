import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login_screen/ui/auth/authentication_bloc.dart'; // Import your authentication bloc

class EditProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Center(
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.authState == AuthState.authenticated) {
              final user = state.user; // Get the current user from the state

              // Display user details
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '-- For debug purpose --',
                    style: TextStyle(fontSize: 18), // Adjust the font size
                  ),
                  Text(
                    'First Name: ${user!.firstName}',
                    style: TextStyle(fontSize: 20), // Adjust the font size
                  ),
                  Text(
                    'Email: ${state.user?.email}',
                    style: TextStyle(fontSize: 20), // Adjust the font size
                  ),
                  Text(
                    'Role: ${state.user?.roles}',
                    style: TextStyle(fontSize: 20), // Adjust the font size
                  ),
                  // Add your profile editing widgets here
                ],
              );
            } else {
              // Handle the case where the user is not authenticated
              return Text(
                'Please log in to edit your profile.',
                style: TextStyle(fontSize: 18), // Adjust the font size
              );
            }
          },
        ),
      ),
    );
  }
}
