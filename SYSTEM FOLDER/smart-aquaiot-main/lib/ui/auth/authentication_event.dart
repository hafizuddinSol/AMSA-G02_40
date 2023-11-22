part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LoginWithEmailAndPasswordEvent extends AuthenticationEvent {
  String email;
  String password;

  LoginWithEmailAndPasswordEvent({
    required this.email,
    required this.password,
  });
}

class AdminLoginEvent extends AuthenticationEvent {
  final String adminEmail;
  final String adminPassword;

  AdminLoginEvent({
    required this.adminEmail,
    required this.adminPassword,
  });
}

class LoginWithFacebookEvent extends AuthenticationEvent {}

class LoginWithAppleEvent extends AuthenticationEvent {}

class LoginWithPhoneNumberEvent extends AuthenticationEvent {
  auth.PhoneAuthCredential credential;
  String phoneNumber;
  String? firstName;
  String? lastName;
  Uint8List? imageData;

  LoginWithPhoneNumberEvent({
    required this.credential,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.imageData,
  });
}

class SignupWithEmailAndPasswordEvent extends AuthenticationEvent {
  String emailAddress;
  String password;
  Uint8List? imageData;
  String? firstName;
  String? lastName;

  SignupWithEmailAndPasswordEvent({
    required this.emailAddress,
    required this.password,
    this.imageData,
    this.firstName,
    this.lastName,
  });
}

class LogoutEvent extends AuthenticationEvent {}

class FinishedOnBoardingEvent extends AuthenticationEvent {}

class CheckFirstRunEvent extends AuthenticationEvent {}
