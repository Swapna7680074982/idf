import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/program_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/metadata_service.dart';
import '../services/token_storage.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterAccountRequested>(_onRegisterAccountRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterForProgramRequested>(_onRegisterForProgramRequested);
    on<CancelProgramRegistrationRequested>(_onCancelProgramRegistrationRequested);
    on<AddProgramRequested>(_onAddProgramRequested);
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<FetchMetadataRequested>(_onFetchMetadataRequested);
    on<SetAuthenticatedUser>(_onSetAuthenticatedUser);
    on<CheckAuthStatus>(_onCheckAuthStatus);

    // Automatically check auth status and fetch metadata on creation
    add(CheckAuthStatus());
    add(FetchMetadataRequested());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AppState> emit,
  ) async {
    await TokenStorage.init();
    final hasTokens = TokenStorage.isAuthenticated ||
        (TokenStorage.refreshToken != null && TokenStorage.refreshToken!.isNotEmpty);

    if (!hasTokens) {
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        user: UserModel.initial(),
      ));
      return;
    }

    if (TokenStorage.currentUser != null) {
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        user: UserModel.fromAuthUser(TokenStorage.currentUser),
      ));
      FirebaseService.syncTokenWithBackend();
    }

    try {
      final liveUser = await AuthService.getMe();
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        user: UserModel.fromAuthUser(liveUser),
      ));
      FirebaseService.syncTokenWithBackend();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await TokenStorage.clearAuth();
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          user: UserModel.initial(),
        ));
      }
      // Keep cached user if offline / network error
    } catch (_) {
      // Keep cached user if offline / socket error
    }
  }

  Future<void> _onFetchMetadataRequested(
    FetchMetadataRequested event,
    Emitter<AppState> emit,
  ) async {
    try {
      final orgTypes = await MetadataService.getOrganizationTypes();
      final countries = await MetadataService.getCountries();

      emit(state.copyWith(
        organizationTypes: orgTypes.map((o) => o.name).toList(),
        countries: countries.map((c) => c.name).toList(),
      ));
    } catch (_) {}
  }

  void _onSetAuthenticatedUser(
    SetAuthenticatedUser event,
    Emitter<AppState> emit,
  ) {
    final userModel = UserModel.fromAuthUser(event.authUser);
    emit(state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: userModel,
      isLoading: false,
    ));
    FirebaseService.syncTokenWithBackend();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await AuthService.login(
        email: event.email,
        password: event.password,
        pushToken: FirebaseService.token,
      );

      final userModel = UserModel.fromAuthUser(result.user);
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        user: userModel,
        isLoading: false,
      ));
      FirebaseService.syncTokenWithBackend();
    } on ApiException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterAccountRequested(
    RegisterAccountRequested event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final newUser = UserModel(
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
      organizationName: event.organizationName,
      organizationType: event.organizationType,
      country: event.country,
      state: event.state,
      city: event.city,
      address: event.address,
      certificationStatus: '',
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
    AuthService.logout();
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

  void _onCancelProgramRegistrationRequested(
    CancelProgramRegistrationRequested event,
    Emitter<AppState> emit,
  ) {
    final updatedPrograms = state.programs.map((p) {
      if (p.id == event.programId) {
        return p.copyWith(isRegistered: false);
      }
      return p;
    }).toList();
    emit(state.copyWith(programs: updatedPrograms));
  }

  void _onAddProgramRequested(
    AddProgramRequested event,
    Emitter<AppState> emit,
  ) {
    if (event.program is ProgramModel) {
      final updatedPrograms = [event.program as ProgramModel, ...state.programs];
      emit(state.copyWith(
        programs: updatedPrograms,
        programApplicationsCount: state.programApplicationsCount + 1,
      ));
    }
  }

  void _onUpdateUserProfileRequested(
    UpdateUserProfileRequested event,
    Emitter<AppState> emit,
  ) {
    final updatedUser = state.user.copyWith(
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
      organizationName: event.organizationName,
      organizationType: event.organizationType,
      country: event.country,
      state: event.state,
      city: event.city,
      address: event.address,
      contactEmail: event.contactEmail,
      contactPhone: event.contactPhone,
    );
    emit(state.copyWith(user: updatedUser));
  }
}
