import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    // LOGIN
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());

      final ok = await repo.login(event.email, event.password);

      if (ok) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Invalid credentials"));
      }
    });

    // REGISTER
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());

      final ok =
      await repo.register(event.name, event.email, event.password);

      if (ok) {
        emit(RegisterSuccess());
      } else {
        emit(AuthFailure("Could not register"));
      }
    });

    // LOGOUT
    on<LogoutEvent>((event, emit) async {
      await repo.logout();
      emit(AuthLoggedOut());
    });
  }
}
