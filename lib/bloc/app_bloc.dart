import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterAccountRequested>(_onRegisterAccountRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterForProgramRequested>(_onRegisterForProgramRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await Future.delayed(const Duration(milliseconds: 500));

    final updatedUser = UserModel(
      fullName: event.email.contains('jane') ? 'Dr. Jane Smith' : 'Dr. Sarah Osei',
      email: event.email.isNotEmpty ? event.email : 'sarah.osei@lasu.edu.ng',
      phone: state.user.phone,
      organizationName: state.user.organizationName,
      organizationType: state.user.organizationType,
      country: state.user.country,
      state: state.user.state,
      city: state.user.city,
      address: state.user.address,
      certificationStatus: 'Changes Required',
    );

    emit(state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: updatedUser,
      isLoading: false,
    ));
  }

  Future<void> _onRegisterAccountRequested(
    RegisterAccountRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await Future.delayed(const Duration(milliseconds: 600));

    final newUser = UserModel(
      fullName: event.fullName.isNotEmpty ? event.fullName : 'Dr. Jane Smith',
      email: event.email.isNotEmpty ? event.email : 'your@email.com',
      phone: event.phone.isNotEmpty ? event.phone : '+91 0987654321',
      organizationName: event.organizationName.isNotEmpty
          ? event.organizationName
          : 'World Health Centre',
      organizationType: event.organizationType.isNotEmpty
          ? event.organizationType
          : 'Hospital / Healthcare Facility',
      country: event.country.isNotEmpty ? event.country : 'India',
      state: event.state.isNotEmpty ? event.state : 'Maharashtra',
      city: event.city.isNotEmpty ? event.city : 'Mumbai',
      address: event.address.isNotEmpty ? event.address : 'Central Medical Ave',
      certificationStatus: 'Under Review',
    );

    emit(state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: newUser,
      isLoading: false,
    ));
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(isLoading: false));
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(
      authStatus: AuthStatus.unauthenticated,
    ));
  }

  void _onRegisterForProgramRequested(
    RegisterForProgramRequested event,
    Emitter<AppState> emit,
  ) {
    final updatedPrograms = state.programs.map((p) {
      if (p.id == event.programId) {
        return p.copyWith(isRegistered: true);
      }
      return p;
    }).toList();
    emit(state.copyWith(programs: updatedPrograms));
  }
}
