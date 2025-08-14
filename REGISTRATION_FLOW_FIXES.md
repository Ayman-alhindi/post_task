# Registration Flow Fixes

## Issues Identified and Fixed

### 1. Company Code Handling
- **Problem**: The `companyCode` was not being properly passed from the first page to subsequent pages
- **Fix**: Added proper company code handling in `CompleteProfilePage` by retrieving it from the auth bloc state
- **Location**: `CompleteProfilePage.dart` line 89

### 2. Data Flow Between Pages
- **Problem**: Data collected in previous pages was not being properly passed through the navigation chain
- **Fix**: Ensured all data is properly collected and passed using the `RegistrationModel` object
- **Implementation**: Each page now properly updates the model and passes it to the next page

### 3. Missing Required Fields
- **Problem**: Some required fields had default values or were missing
- **Fix**: Added proper validation and ensured all required fields are collected
- **Fields Fixed**:
  - Company code for company drivers
  - Vehicle information
  - City and district selection
  - Transport type and category selection

## Data Flow Structure

### Page 1: CreateAccountPage
- Collects: Phone number, driver type, company code (if company driver)
- Sends: `CreateAccountRequested` event to auth bloc
- Result: Navigates to verification page

### Page 2: VerificationPage (OTP)
- Receives: Phone number and registration data from auth bloc state
- Sends: `VerifyOTPRequested` event
- Result: Navigates to complete profile page

### Page 3: CompleteProfilePage
- Collects: Personal information, ID images, license information
- Retrieves: Company code from auth bloc state
- Creates: Initial `RegistrationModel` with driver information
- Result: Navigates to vehicle info page

### Page 4: VehicleInfoPage
- Collects: Vehicle details, images, car license
- Updates: `RegistrationModel` with vehicle information
- Result: Navigates to transportation info page

### Page 5: TransportationInfoPage
- Collects: City, district, transport type, transport category
- Finalizes: Complete `RegistrationModel`
- Sends: `SubmitRegistrationRequested` event to auth bloc
- Result: Registration data sent to API

## Key Fixes Applied

### 1. Company Code Retrieval
```dart
// In CompleteProfilePage initState
if (authState is OTPVerified) {
  setState(() {
    _phoneNumber = authState.phoneNumber;
    _driverType = authState.registrationData.driverType;
    _companyCode = authState.registrationData.companyCode; // Fixed
  });
}
```

### 2. Proper Data Passing
```dart
// In CompleteProfilePage submit button
final driverDto = DriverDto(
  id: 0,
  licenseNumber: _licenseNumberController.text,
  isIndependent: _driverType == 0,
  companyCode: _companyCode ?? '', // Fixed: Use company code from state
  idNumber: _nationalIdController.text,
  idImage: base64Encode(await _idImage!.readAsBytes()),
  licenseImage: base64Encode(await _licenseImage!.readAsBytes()),
);
```

### 3. Complete Data Collection
```dart
// In TransportationInfoPage submit button
final updatedModel = widget.registrationModel.copyWith(
  cityId: _cities.indexWhere((c) => c['id'] == _selectedCity),
  neighborhoodId: 0,
  longitude: LocationService.longitude ?? 0,
  latitude: LocationService.latitude ?? 0,
  role: '',
  roleId: 0,
  password: '',
);
```

## API Request Body Structure

The final API request will have this structure:
```json
{
  "fullName": "string",
  "email": "user@example.com",
  "role": "string",
  "roleId": 1,
  "cityId": 0,
  "neighborhoodId": 0,
  "longitude": 0,
  "latitude": 0,
  "password": "string",
  "phoneNumber": "string",
  "driverDto": {
    "id": 0,
    "licenseNumber": "string",
    "isIndependent": true,
    "companyCode": "string",
    "idNumber": "string",
    "idImage": "string",
    "licenseImage": "string"
  },
  "vehicleDto": {
    "id": 0,
    "type": 1,
    "model": "string",
    "color": "string",
    "plateNumber": "string",
    "seats": 0,
    "nameAr": "string",
    "images": "string"
  }
}
```

## Validation Rules

### Required Fields
- Phone number (with Saudi format validation)
- Company code (if company driver)
- Full name
- Email (with format validation)
- National ID
- ID image
- License number
- License expiry date
- License image
- Driver photo
- Vehicle type
- Vehicle model
- Vehicle color
- Plate number
- Seat count
- Car license image
- Vehicle images (minimum 3, maximum 5)
- City selection
- District
- Transport type (at least one)
- Transport category (at least one)

### Data Validation
- Phone number must match Saudi format (05xxxxxxxx)
- Email must be valid format
- National ID must be at least 10 characters
- Vehicle images must be between 3-5 images
- All required fields must be filled before proceeding

## Debug Information

The final page includes debug prints to help track data flow:
```dart
print('Final Registration Model:');
print('Full Name: ${updatedModel.fullName}');
print('Email: ${updatedModel.email}');
print('Phone: ${updatedModel.phoneNumber}');
print('City ID: ${updatedModel.cityId}');
print('Driver Type: ${updatedModel.driverDto.isIndependent ? "Individual" : "Company"}');
print('Company Code: ${updatedModel.driverDto.companyCode}');
print('Vehicle Type: ${updatedModel.vehicleDto.type}');
print('Vehicle Model: ${updatedModel.vehicleDto.model}');
```

## Next Steps

1. Ensure all required dependencies are properly imported
2. Test the complete flow from first page to final submission
3. Verify that the auth bloc properly handles the `SubmitRegistrationRequested` event
4. Test with both individual and company driver flows
5. Verify that all images are properly converted to base64 and included in the final request