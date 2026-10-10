import 'package:equatable/equatable.dart';
import '../models/program_model.dart';

// Models
class UserModel extends Equatable {
  final String fullName;
  final String email;
  final String phone;
  final String organizationName;
  final String organizationType;
  final String country;
  final String state;
  final String city;
  final String address;
  final String certificationStatus;

  const UserModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.organizationName,
    required this.organizationType,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.certificationStatus,
  });

  factory UserModel.initial() {
    return const UserModel(
      fullName: 'Dr. Sarah Osei',
      email: 'sarah.osei@lasu.edu.ng',
      phone: '+91 0987654321',
      organizationName: 'Lagos State University',
      organizationType: 'College / University',
      country: 'Nigeria',
      state: 'Lagos',
      city: 'Ojo',
      address: 'Badagry Expressway, Ojo, Lagos',
      certificationStatus: 'Changes Required',
    );
  }

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
        certificationStatus,
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
      programApplicationsCount: 2,
      certificationApplicationsCount: 1,
      registeredPrograms: const [
        ProgramItem(
          tag: 'CAMPAIGN',
          title: 'Diabetes Awareness Walk 2026',
          date: '18 Sep 2026',
          location: 'Hyderabad, India',
          isRegistered: true,
          gradientColors: [0xFFEA580C, 0xFFF97316],
          imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&auto=format&fit=crop&q=80',
        ),
        ProgramItem(
          tag: 'ACTIVITY DRIVE',
          title: 'Global Walk for Diabetes 2025',
          date: '14 Nov 2025',
          location: 'Nairobi, Kenya',
          isRegistered: true,
          gradientColors: [0xFF006097, 0xFF017CC2],
          imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop&q=80',
        ),
        ProgramItem(
          tag: 'CAMPAIGN',
          title: 'Community Cycling Campaign – SEA',
          date: '10 Aug 2025',
          location: 'Bangkok, Thailand',
          isRegistered: true,
          gradientColors: [0xFF059669, 0xFF10B981],
          imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80',
        ),
      ],
      programs: ProgramModel.samplePrograms(),
      organizationTypes: const [
        'Hospital / Healthcare Facility',
        'NGO / Non-profit Organization',
        'Academic / Research Institution',
        'Government / Public Health Agency',
        'Corporate / Fitness Organization',
        'Other',
      ],
      countries: const [
        'India',
        'United States',
        'United Kingdom',
        'Canada',
        'Australia',
        'Germany',
        'France',
        'Singapore',
        'Nigeria',
        'United Arab Emirates',
      ],
      states: const [
        'Maharashtra',
        'Delhi',
        'Karnataka',
        'Tamil Nadu',
        'Telangana',
        'Gujarat',
        'West Bengal',
        'California',
        'New York',
        'London Region',
        'Lagos',
        'Other',
      ],
      cities: const [
        'Mumbai',
        'New Delhi',
        'Bengaluru',
        'Chennai',
        'Hyderabad',
        'Pune',
        'Kolkata',
        'San Francisco',
        'London',
        'Ikeja',
        'Other',
      ],
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
