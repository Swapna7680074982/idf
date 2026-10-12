import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AppEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterAccountRequested extends AppEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String organizationName;
  final String organizationType;
  final String country;
  final String state;
  final String city;
  final String address;

  const RegisterAccountRequested({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.organizationName,
    required this.organizationType,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        password,
        organizationName,
        organizationType,
        country,
        state,
        city,
        address,
      ];
}

class ResetPasswordRequested extends AppEvent {
  final String email;
  final String newPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, newPassword];
}

class LogoutRequested extends AppEvent {}

class RegisterForProgramRequested extends AppEvent {
  final String programId;

  const RegisterForProgramRequested(this.programId);

  @override
  List<Object?> get props => [programId];
}

class AddProgramRequested extends AppEvent {
  final dynamic program;

  const AddProgramRequested(this.program);

  @override
  List<Object?> get props => [program];
}

class UpdateUserProfileRequested extends AppEvent {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? organizationName;
  final String? organizationType;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;

  const UpdateUserProfileRequested({
    this.fullName,
    this.email,
    this.phone,
    this.organizationName,
    this.organizationType,
    this.country,
    this.state,
    this.city,
    this.address,
    this.contactEmail,
    this.contactPhone,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        phone,
        organizationName,
        organizationType,
        country,
        state,
        city,
        address,
        contactEmail,
        contactPhone,
      ];
}
