import 'package:bloc/bloc.dart';

part 'welcome_event.dart';

part 'welcome_state.dart';

class AdminLoginPressed extends WelcomeEvent {}

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeInitial> {
  WelcomeBloc() : super(WelcomeInitial()) {
    on<LoginPressed>((event, emit) {
      emit(WelcomeInitial(pressTarget: WelcomePressTarget.login));
    });
    on<SignupPressed>((event, emit) {
      emit(WelcomeInitial(pressTarget: WelcomePressTarget.signup));
    });
on<AdminLoginRequested>((event, emit) {
  emit(WelcomeInitial(pressTarget: WelcomePressTarget.adminLogin));
});
    }
  }

