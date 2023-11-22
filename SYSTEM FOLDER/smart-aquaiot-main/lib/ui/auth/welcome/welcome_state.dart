part of 'welcome_bloc.dart';

enum WelcomePressTarget { login, signup, adminLogin }

class WelcomeInitial {
  WelcomePressTarget? pressTarget;

  WelcomeInitial({this.pressTarget});
}
