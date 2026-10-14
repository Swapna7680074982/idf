import 'package:equatable/equatable.dart';
import '../models/program_model.dart';

// Models
class UserModel extends Equatable {
  final int? id;
  final String fullName;
  final String email;
  final String phone;
  final String organizationName;
  final int? organizationTypeId;
  final String organizationType;
  final int? countryId;
  final String country;
  final int? regionId;
  final String state;
  final int? cityId;
  final String city;
  final String address;
  final String certificationStatus;
  final String contactEmail;
  final String contactPhone;
  final String role;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.organizationName,
    this.organizationTypeId,
    required this.organizationType,
    this.countryId,
    required this.country,
    this.regionId,
    required this.state,
    this.cityId,
    required this.city,
    required this.address,
    required this.certificationStatus,
    this.contactEmail = '',
    this.contactPhone = '',
    this.role = 'user',
  });

  factory UserModel.initial() {
    return const UserModel(
      id: null,
      fullName: '',
      email: '',
      phone: '',
      organizationName: '',
      organizationTypeId: null,
      organizationType: '',
      countryId: null,
      country: '',
      regionId: null,
      state: '',
      cityId: null,
      city: '',
      address: '',
      certificationStatus: '',
      contactEmail: '',
      contactPhone: '',
      role: 'user',
    );
  }

  factory UserModel.fromAuthUser(dynamic authUser) {
    if (authUser == null) return UserModel.initial();
    return UserModel(
      id: authUser.id is int ? authUser.id as int : null,
      fullName: authUser.fullName?.toString() ?? '',
      email: authUser.email?.toString() ?? '',
      phone: authUser.phoneNumber?.toString() ?? '',
      organizationName: authUser.organization?.name?.toString() ?? '',
      organizationTypeId: authUser.organization?.organizationTypeId is int
          ? authUser.organization?.organizationTypeId as int
          : int.tryParse(authUser.organization?.organizationTypeId?.toString() ?? ''),
      organizationType: authUser.organization?.organizationType?.toString() ?? '',
      countryId: authUser.organization?.countryId is int
          ? authUser.organization?.countryId as int
          : int.tryParse(authUser.organization?.countryId?.toString() ?? ''),
      country: authUser.organization?.country?.toString() ?? '',
      regionId: authUser.organization?.regionId is int
          ? authUser.organization?.regionId as int
          : int.tryParse(authUser.organization?.regionId?.toString() ?? ''),
      state: authUser.organization?.region?.toString() ?? '',
      cityId: authUser.organization?.cityId is int
          ? authUser.organization?.cityId as int
          : int.tryParse(authUser.organization?.cityId?.toString() ?? ''),
      city: authUser.organization?.city?.toString() ?? '',
      address: authUser.organization?.address?.toString() ?? '',
      certificationStatus: '',
      contactEmail: authUser.organization?.contactEmail?.toString() ?? authUser.email?.toString() ?? '',
      contactPhone: authUser.organization?.contactPhone?.toString() ?? authUser.phoneNumber?.toString() ?? '',
      role: authUser.role?.toString() ?? 'user',
    );
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? organizationName,
    int? organizationTypeId,
    String? organizationType,
    int? countryId,
    String? country,
    int? regionId,
    String? state,
    int? cityId,
    String? city,
    String? address,
    String? certificationStatus,
    String? contactEmail,
    String? contactPhone,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organizationName: organizationName ?? this.organizationName,
      organizationTypeId: organizationTypeId ?? this.organizationTypeId,
      organizationType: organizationType ?? this.organizationType,
      countryId: countryId ?? this.countryId,
      country: country ?? this.country,
      regionId: regionId ?? this.regionId,
      state: state ?? this.state,
      cityId: cityId ?? this.cityId,
      city: city ?? this.city,
      address: address ?? this.address,
      certificationStatus: certificationStatus ?? this.certificationStatus,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        organizationName,
        organizationTypeId,
        organizationType,
        countryId,
        country,
        regionId,
        state,
        cityId,
        city,
        address,
        certificationStatus,
        contactEmail,
        contactPhone,
        role,
      ];
}

class ProgramItem extends Equatable {
  final String tag;
  final String title;
  final String date;
  final String location;
  final bool isRegistered;
  final List<int> gradientColors;
  final String? imageUrl;

  const ProgramItem({
    required this.tag,
    required this.title,
    required this.date,
    required this.location,
    required this.isRegistered,
    required this.gradientColors,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [tag, title, date, location, isRegistered, gradientColors, imageUrl];
}

// -------------------------------------------------------------
// App State
// -------------------------------------------------------------
enum AuthStatus { unauthenticated, authenticating, authenticated }

class AppState extends Equatable {
  final AuthStatus authStatus;
  final UserModel user;
  final int programApplicationsCount;
  final int certificationApplicationsCount;
  final List<ProgramItem> registeredPrograms;
  final List<ProgramModel> programs;
  final List<String> organizationTypes;
  final List<String> countries;
  final List<String> states;
  final List<String> cities;
  final String? errorMessage;
  final bool isLoading;

  const AppState({
    required this.authStatus,
    required this.user,
    required this.programApplicationsCount,
    required this.certificationApplicationsCount,
    required this.registeredPrograms,
    required this.programs,
    required this.organizationTypes,
    required this.countries,
    required this.states,
    required this.cities,
    this.errorMessage,
    this.isLoading = false,
  });

  factory AppState.initial() {
    return AppState(
      authStatus: AuthStatus.unauthenticated,
      user: UserModel.initial(),
      programApplicationsCount: 0,
      certificationApplicationsCount: 0,
      registeredPrograms: const [],
      programs: const [],
      organizationTypes: const [],
      countries: const [],
      states: const [],
      cities: const [],
    );
  }

  AppState copyWith({
    AuthStatus? authStatus,
    UserModel? user,
    int? programApplicationsCount,
    int? certificationApplicationsCount,
    List<ProgramItem>? registeredPrograms,
    List<ProgramModel>? programs,
    List<String>? organizationTypes,
    List<String>? countries,
    List<String>? states,
    List<String>? cities,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AppState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      programApplicationsCount:
          programApplicationsCount ?? this.programApplicationsCount,
      certificationApplicationsCount:
          certificationApplicationsCount ?? this.certificationApplicationsCount,
      registeredPrograms: registeredPrograms ?? this.registeredPrograms,
      programs: programs ?? this.programs,
      organizationTypes: organizationTypes ?? this.organizationTypes,
      countries: countries ?? this.countries,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        authStatus,
        user,
        programApplicationsCount,
        certificationApplicationsCount,
        registeredPrograms,
        programs,
        organizationTypes,
        countries,
        states,
        cities,
        errorMessage,
        isLoading,
      ];
}
