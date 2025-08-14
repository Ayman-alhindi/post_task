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