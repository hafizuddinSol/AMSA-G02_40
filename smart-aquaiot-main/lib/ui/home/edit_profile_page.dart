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
                  Text('-- For debug purpose --'),
                  Text('First Name: ${user!.firstName}'),
                  Text('Email: ${state.user?.email}'),
                  Text('Roles: ${state.user?.roles}'),
                  // Add your profile editing widgets here
                ],
              );
            } else {
              // Handle the case where the user is not authenticated
              return Text('Please log in to edit your profile.');
            }
          },
        ),
      ),
    );
  }
}
