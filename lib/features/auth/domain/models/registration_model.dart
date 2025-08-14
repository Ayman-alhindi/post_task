class RegistrationData {
  final String? phoneNumber;
  final int? driverType; // 0 = Individual, 1 = Company
  final String? companyCode;
  final bool isLogin;
  
  // Profile data
  final String? fullName;
  final String? email;
  final String? nationalId;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? driverPhoto; // base64
  final String? idImage; // base64
  final String? licenseImage; // base64
  
  // Vehicle data
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? plateNumber;
  final int? seats;
  final String? carLicenseImage; // base64
  final List<String>? vehicleImages; // List of base64 images
  
  // Transportation data
  final int? cityId;
  final String? district;
  final bool? isShared;
  final bool? isPrivate;
  final bool? schoolStudents;
  final bool? universityStudents;
  final bool? employees;

  const RegistrationData({
    this.phoneNumber,
    this.driverType,
    this.companyCode,
    this.isLogin = false,
    this.fullName,
    this.email,
    this.nationalId,
    this.licenseNumber,
    this.licenseExpiry,
    this.driverPhoto,
    this.idImage,
    this.licenseImage,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.plateNumber,
    this.seats,
    this.carLicenseImage,
    this.vehicleImages,
    this.cityId,
    this.district,
    this.isShared,
    this.isPrivate,
    this.schoolStudents,
    this.universityStudents,
    this.employees,
  });

  RegistrationData copyWith({
    String? phoneNumber,
    int? driverType,
    String? companyCode,
    bool? isLogin,
    String? fullName,
    String? email,
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? driverPhoto,
    String? idImage,
    String? licenseImage,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    String? plateNumber,
    int? seats,
    String? carLicenseImage,
    List<String>? vehicleImages,
    int? cityId,
    String? district,
    bool? isShared,
    bool? isPrivate,
    bool? schoolStudents,
    bool? universityStudents,
    bool? employees,
  }) {
    return RegistrationData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      driverType: driverType ?? this.driverType,
      companyCode: companyCode ?? this.companyCode,
      isLogin: isLogin ?? this.isLogin,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      nationalId: nationalId ?? this.nationalId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      idImage: idImage ?? this.idImage,
      licenseImage: licenseImage ?? this.licenseImage,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      plateNumber: plateNumber ?? this.plateNumber,
      seats: seats ?? this.seats,
      carLicenseImage: carLicenseImage ?? this.carLicenseImage,
      vehicleImages: vehicleImages ?? this.vehicleImages,
      cityId: cityId ?? this.cityId,
      district: district ?? this.district,
      isShared: isShared ?? this.isShared,
      isPrivate: isPrivate ?? this.isPrivate,
      schoolStudents: schoolStudents ?? this.schoolStudents,
      universityStudents: universityStudents ?? this.universityStudents,
      employees: employees ?? this.employees,
    );
  }

  RegistrationModel toRegistrationModel() {
    final driverDto = DriverDto(
      id: 0,
      licenseNumber: licenseNumber ?? '',
      isIndependent: driverType == 0,
      companyCode: companyCode ?? '',
      idNumber: nationalId ?? '',
      idImage: idImage ?? '',
      licenseImage: licenseImage ?? '',
    );

    final vehicleDto = VehicleDto(
      id: 0,
      type: _getVehicleTypeId(vehicleType),
      model: vehicleModel ?? '',
      color: vehicleColor ?? '',
      plateNumber: plateNumber ?? '',
      seats: seats ?? 0,
      nameAr: vehicleType ?? '',
      images: vehicleImages?.join(',') ?? '',
    );

    return RegistrationModel(
      fullName: fullName ?? '',
      email: email ?? '',
      role: 'driver',
      roleId: 1,
      cityId: cityId ?? 0,
      neighborhoodId: 0,
      longitude: 0,
      latitude: 0,
      password: '',
      phoneNumber: phoneNumber ?? '',
      driverDto: driverDto,
      vehicleDto: vehicleDto,
    );
  }

  int _getVehicleTypeId(String? type) {
    switch (type) {
      case 'Sedan':
        return 0;
      case 'SUV':
        return 1;
      case 'Hatchback':
        return 2;
      case 'Truck':
        return 3;
      case 'Van':
        return 4;
      default:
        return 0;
    }
  }
}

class RegistrationModel {
  final String fullName;
  final String email;
  final String role;
  final int roleId;
  final int cityId;
  final int neighborhoodId;
  final double longitude;
  final double latitude;
  final String password;
  final String phoneNumber;
  final DriverDto driverDto;
  final VehicleDto vehicleDto;

  RegistrationModel({
    required this.fullName,
    required this.email,
    required this.role,
    required this.roleId,
    required this.cityId,
    required this.neighborhoodId,
    required this.longitude,
    required this.latitude,
    required this.password,
    required this.phoneNumber,
    required this.driverDto,
    required this.vehicleDto,
  });

  RegistrationModel copyWith({
    String? fullName,
    String? email,
    String? role,
    int? roleId,
    int? cityId,
    int? neighborhoodId,
    double? longitude,
    double? latitude,
    String? password,
    String? phoneNumber,
    DriverDto? driverDto,
    VehicleDto? vehicleDto,
  }) {
    return RegistrationModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      cityId: cityId ?? this.cityId,
      neighborhoodId: neighborhoodId ?? this.neighborhoodId,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      driverDto: driverDto ?? this.driverDto,
      vehicleDto: vehicleDto ?? this.vehicleDto,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'role': role,
        'roleId': roleId,
        'cityId': cityId,
        'neighborhoodId': neighborhoodId,
        'longitude': longitude,
        'latitude': latitude,
        'password': password,
        'phoneNumber': phoneNumber,
        'driverDto': driverDto.toJson(),
        'vehicleDto': vehicleDto.toJson(),
      };
}

class DriverDto {
  final int id;
  final String licenseNumber;
  final bool isIndependent;
  final String companyCode;
  final String idNumber;
  final String idImage;
  final String licenseImage;

  DriverDto({
    required this.id,
    required this.licenseNumber,
    required this.isIndependent,
    required this.companyCode,
    required this.idNumber,
    required this.idImage,
    required this.licenseImage,
  });

  DriverDto copyWith({
    int? id,
    String? licenseNumber,
    bool? isIndependent,
    String? companyCode,
    String? idNumber,
    String? idImage,
    String? licenseImage,
  }) {
    return DriverDto(
      id: id ?? this.id,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      isIndependent: isIndependent ?? this.isIndependent,
      companyCode: companyCode ?? this.companyCode,
      idNumber: idNumber ?? this.idNumber,
      idImage: idImage ?? this.idImage,
      licenseImage: licenseImage ?? this.licenseImage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'licenseNumber': licenseNumber,
        'isIndependent': isIndependent,
        'companyCode': companyCode,
        'idNumber': idNumber,
        'idImage': idImage,
        'licenseImage': licenseImage,
      };
}

class VehicleDto {
  final int id;
  final int type;
  final String model;
  final String color;
  final String plateNumber;
  final int seats;
  final String nameAr;
  final String images;

  VehicleDto({
    required this.id,
    required this.type,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.seats,
    required this.nameAr,
    required this.images,
  });

  VehicleDto copyWith({
    int? id,
    int? type,
    String? model,
    String? color,
    String? plateNumber,
    int? seats,
    String? nameAr,
    String? images,
  }) {
    return VehicleDto(
      id: id ?? this.id,
      type: type ?? this.type,
      model: model ?? this.model,
      color: color ?? this.color,
      plateNumber: plateNumber ?? this.plateNumber,
      seats: seats ?? this.seats,
      nameAr: nameAr ?? this.nameAr,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'model': model,
        'color': color,
        'plateNumber': plateNumber,
        'seats': seats,
        'nameAr': nameAr,
        'images': images,
      };
}