import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/registration_model.dart';
import '../../data/api/auth_api_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CreateAccountRequested extends AuthEvent {
  final String phoneNumber;
  final int driverType;
  final String? companyCode;

  const CreateAccountRequested({
    required this.phoneNumber,
    required this.driverType,
    this.companyCode,
  });

  @override
  List<Object?> get props => [phoneNumber, driverType, companyCode];
}

class SendLoginOTPRequested extends AuthEvent {
  final String phoneNumber;

  const SendLoginOTPRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOTPRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOTPRequested({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class ProfileDataUpdated extends AuthEvent {
  final String fullName;
  final String email;
  final String nationalId;
  final String licenseNumber;
  final String licenseExpiry;
  final String driverPhoto;
  final String idImage;
  final String licenseImage;

  const ProfileDataUpdated({
    required this.fullName,
    required this.email,
    required this.nationalId,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.driverPhoto,
    required this.idImage,
    required this.licenseImage,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        nationalId,
        licenseNumber,
        licenseExpiry,
        driverPhoto,
        idImage,
        licenseImage,
      ];
}

class VehicleDataUpdated extends AuthEvent {
  final String vehicleType;
  final String vehicleModel;
  final String vehicleColor;
  final String plateNumber;
  final int seats;
  final String carLicenseImage;
  final List<String> vehicleImages;

  const VehicleDataUpdated({
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.plateNumber,
    required this.seats,
    required this.carLicenseImage,
    required this.vehicleImages,
  });

  @override
  List<Object?> get props => [
        vehicleType,
        vehicleModel,
        vehicleColor,
        plateNumber,
        seats,
        carLicenseImage,
        vehicleImages,
      ];
}

class SubmitRegistrationRequested extends AuthEvent {
  final int cityId;
  final String district;
  final bool isShared;
  final bool isPrivate;
  final bool schoolStudents;
  final bool universityStudents;
  final bool employees;

  const SubmitRegistrationRequested({
    required this.cityId,
    required this.district,
    required this.isShared,
    required this.isPrivate,
    required this.schoolStudents,
    required this.universityStudents,
    required this.employees,
  });

  @override
  List<Object?> get props => [
        cityId,
        district,
        isShared,
        isPrivate,
        schoolStudents,
        universityStudents,
        employees,
      ];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OTPSent extends AuthState {
  final String phoneNumber;
  final RegistrationData registrationData;

  const OTPSent({
    required this.phoneNumber,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [phoneNumber, registrationData];
}

class OTPVerified extends AuthState {
  final String phoneNumber;
  final RegistrationData registrationData;

  const OTPVerified({
    required this.phoneNumber,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [phoneNumber, registrationData];
}

class ProfileDataCollected extends AuthState {
  final RegistrationData registrationData;

  const ProfileDataCollected({required this.registrationData});

  @override
  List<Object?> get props => [registrationData];
}

class VehicleDataCollected extends AuthState {
  final RegistrationData registrationData;

  const VehicleDataCollected({required this.registrationData});

  @override
  List<Object?> get props => [registrationData];
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({this.message = 'Registration successful'});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService _apiService;
  RegistrationData _currentRegistrationData = const RegistrationData();

  AuthBloc({AuthApiService? apiService}) 
      : _apiService = apiService ?? AuthApiService(),
        super(AuthInitial()) {
    on<CreateAccountRequested>(_onCreateAccountRequested);
    on<SendLoginOTPRequested>(_onSendLoginOTPRequested);
    on<VerifyOTPRequested>(_onVerifyOTPRequested);
    on<ProfileDataUpdated>(_onProfileDataUpdated);
    on<VehicleDataUpdated>(_onVehicleDataUpdated);
    on<SubmitRegistrationRequested>(_onSubmitRegistrationRequested);
  }

  Future<void> _onCreateAccountRequested(
    CreateAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Call API to send registration OTP
      await _apiService.sendRegistrationOTP(
        phoneNumber: event.phoneNumber,
        driverType: event.driverType,
        companyCode: event.companyCode,
      );
      
      _currentRegistrationData = _currentRegistrationData.copyWith(
        phoneNumber: event.phoneNumber,
        driverType: event.driverType,
        companyCode: event.companyCode,
        isLogin: false,
      );
      
      emit(OTPSent(
        phoneNumber: event.phoneNumber,
        registrationData: _currentRegistrationData,
      ));
    } catch (e) {
      emit(AuthError(message: 'Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onSendLoginOTPRequested(
    SendLoginOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Call API to send login OTP
      await _apiService.sendLoginOTP(phoneNumber: event.phoneNumber);
      
      _currentRegistrationData = _currentRegistrationData.copyWith(
        phoneNumber: event.phoneNumber,
        isLogin: true,
      );
      
      emit(OTPSent(
        phoneNumber: event.phoneNumber,
        registrationData: _currentRegistrationData,
      ));
    } catch (e) {
      emit(AuthError(message: 'Failed to send login OTP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOTPRequested(
    VerifyOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Call API to verify OTP
      final result = await _apiService.verifyOTP(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
        isLogin: _currentRegistrationData.isLogin,
      );
      
      if (_currentRegistrationData.isLogin) {
        // For login flow, complete login
        await _apiService.loginUser(phoneNumber: event.phoneNumber);
        emit(const AuthSuccess(message: 'Login successful'));
      } else {
        // For registration flow, continue to profile completion
        emit(OTPVerified(
          phoneNumber: event.phoneNumber,
          registrationData: _currentRegistrationData,
        ));
      }
    } catch (e) {
      emit(AuthError(message: 'Failed to verify OTP: ${e.toString()}'));
    }
  }

  Future<void> _onProfileDataUpdated(
    ProfileDataUpdated event,
    Emitter<AuthState> emit,
  ) async {
    _currentRegistrationData = _currentRegistrationData.copyWith(
      fullName: event.fullName,
      email: event.email,
      nationalId: event.nationalId,
      licenseNumber: event.licenseNumber,
      licenseExpiry: event.licenseExpiry,
      driverPhoto: event.driverPhoto,
      idImage: event.idImage,
      licenseImage: event.licenseImage,
    );
    
    emit(ProfileDataCollected(registrationData: _currentRegistrationData));
  }

  Future<void> _onVehicleDataUpdated(
    VehicleDataUpdated event,
    Emitter<AuthState> emit,
  ) async {
    _currentRegistrationData = _currentRegistrationData.copyWith(
      vehicleType: event.vehicleType,
      vehicleModel: event.vehicleModel,
      vehicleColor: event.vehicleColor,
      plateNumber: event.plateNumber,
      seats: event.seats,
      carLicenseImage: event.carLicenseImage,
      vehicleImages: event.vehicleImages,
    );
    
    emit(VehicleDataCollected(registrationData: _currentRegistrationData));
  }

  Future<void> _onSubmitRegistrationRequested(
    SubmitRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      _currentRegistrationData = _currentRegistrationData.copyWith(
        cityId: event.cityId,
        district: event.district,
        isShared: event.isShared,
        isPrivate: event.isPrivate,
        schoolStudents: event.schoolStudents,
        universityStudents: event.universityStudents,
        employees: event.employees,
      );
      
      // Convert to RegistrationModel and submit to API
      final registrationModel = _currentRegistrationData.toRegistrationModel();
      
      // Submit registration to API
      final result = await _apiService.submitRegistration(
        registrationModel: registrationModel,
      );
      
      print('Registration successful: $result');
      
      emit(const AuthSuccess(message: 'Registration completed successfully'));
      
      // Reset the registration data for next use
      _currentRegistrationData = const RegistrationData();
      
    } catch (e) {
      emit(AuthError(message: 'Failed to complete registration: ${e.toString()}'));
    }
  }

  // Getter to access current registration data
  RegistrationData get currentRegistrationData => _currentRegistrationData;
}