# Fixed Registration Flow Documentation

## Overview
The registration flow has been completely redesigned to ensure proper data continuity across all pages, from the initial account creation to the final API submission. The system now uses a robust BLoC architecture to maintain state throughout the entire process.

## Architecture

### 1. BLoC Pattern Implementation
- **AuthBloc**: Central state management for the entire registration flow
- **Events**: Specific actions that trigger state changes
- **States**: Different stages of the registration process
- **RegistrationData**: Comprehensive model that holds all data throughout the flow

### 2. Data Flow Structure

```
CreateAccountPage → VerificationPage → CompleteProfilePage → VehicleInfoPage → TransportationInfoPage
       ↓                    ↓                    ↓                    ↓                    ↓
   Phone Number         OTP Code          Profile Data          Vehicle Data      Transportation Data
   Driver Type                           Personal Info          Car Details       Service Categories
   Company Code                          Documents              Images            Location Info
```

## File Structure

```
lib/features/auth/
├── data/
│   └── api/
│       └── auth_api_service.dart          # API integration
├── domain/
│   └── models/
│       └── registration_model.dart        # Data models
└── presentation/
    ├── bloc/
    │   └── auth_bloc.dart                 # State management
    └── pages/
        ├── create_account_page.dart       # Step 1: Basic info
        ├── verification_page.dart         # Step 2: OTP verification
        ├── complete_profile_page.dart     # Step 3: Profile completion
        ├── vehicle_info_page.dart         # Step 4: Vehicle details
        └── transportation_info_page.dart  # Step 5: Final submission
```

## Registration Flow Steps

### Step 1: Create Account (CreateAccountPage)
**Data Collected:**
- Phone number
- Driver type (Individual/Company)
- Company code (if applicable)

**BLoC Event:** `CreateAccountRequested`
**Next State:** `OTPSent`

### Step 2: OTP Verification (VerificationPage)
**Data Collected:**
- OTP code verification

**BLoC Event:** `VerifyOTPRequested`
**Next State:** `OTPVerified` (for registration) or `AuthSuccess` (for login)

### Step 3: Complete Profile (CompleteProfilePage)
**Data Collected:**
- Full name
- Email address
- National ID number
- Driver license number
- License expiry date
- Driver photo (base64)
- ID image (base64)
- License image (base64)

**BLoC Event:** `ProfileDataUpdated`
**Next State:** `ProfileDataCollected`

### Step 4: Vehicle Information (VehicleInfoPage)
**Data Collected:**
- Vehicle type (Sedan, SUV, etc.)
- Vehicle model/year
- Vehicle color
- Plate number
- Seat count
- Car license image (base64)
- Vehicle images (3-5 photos, base64)

**BLoC Event:** `VehicleDataUpdated`
**Next State:** `VehicleDataCollected`

### Step 5: Transportation Info (TransportationInfoPage)
**Data Collected:**
- City selection
- District/neighborhood
- Transport type (Shared/Private)
- Service categories (School/University/Employees)

**BLoC Event:** `SubmitRegistrationRequested`
**Final State:** `AuthSuccess`

## API Integration

The system integrates with a backend API through the `AuthApiService` class:

### API Endpoints:
1. **POST** `/auth/send-registration-otp` - Send OTP for registration
2. **POST** `/auth/send-login-otp` - Send OTP for login
3. **POST** `/auth/verify-registration-otp` - Verify registration OTP
4. **POST** `/auth/verify-login-otp` - Verify login OTP
5. **POST** `/auth/complete-registration` - Submit complete registration data
6. **POST** `/auth/login` - Complete login process

### Final API Payload Structure:
```json
{
  "fullName": "string",
  "email": "user@example.com",
  "role": "driver",
  "roleId": 1,
  "cityId": 0,
  "neighborhoodId": 0,
  "longitude": 0,
  "latitude": 0,
  "password": "",
  "phoneNumber": "string",
  "driverDto": {
    "id": 0,
    "licenseNumber": "string",
    "isIndependent": true,
    "companyCode": "string",
    "idNumber": "string",
    "idImage": "base64_string",
    "licenseImage": "base64_string"
  },
  "vehicleDto": {
    "id": 0,
    "type": 1,
    "model": "string",
    "color": "string",
    "plateNumber": "string",
    "seats": 4,
    "nameAr": "string",
    "images": "base64_image1,base64_image2,base64_image3"
  }
}
```

## Key Features

### 1. Data Persistence
- All data is maintained in the BLoC's `RegistrationData` object
- Users can navigate back and forth without losing data
- Form validation ensures data integrity at each step

### 2. Error Handling
- Comprehensive error messages for API failures
- Form validation with localized error messages
- Network error handling with user-friendly feedback

### 3. Image Handling
- Support for both web and mobile platforms
- Automatic base64 conversion for API submission
- Image preview and validation
- Multiple image upload with management

### 4. Localization Support
- Arabic and English language support
- Proper RTL layout handling
- Localized validation messages

### 5. Navigation Flow
- Proper back navigation support
- State preservation across page transitions
- Loading states during API calls

## Usage Instructions

### 1. Initialize the BLoC
```dart
// In your main app or page where you provide the BLoC
BlocProvider<AuthBloc>(
  create: (context) => AuthBloc(),
  child: CreateAccountPage(),
)
```

### 2. Handle State Changes
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is OTPSent) {
      // Navigate to verification page
    } else if (state is AuthSuccess) {
      // Navigate to home page
    } else if (state is AuthError) {
      // Show error message
    }
  },
  child: YourWidget(),
)
```

### 3. Access Current Registration Data
```dart
final authBloc = context.read<AuthBloc>();
final currentData = authBloc.currentRegistrationData;
```

## Testing the Flow

### For Development (Simulated API):
1. Change the `baseUrl` in `AuthApiService` to a test server
2. The current implementation will print registration data to console
3. Use the debug panel in `TransportationInfoPage` to verify data collection

### For Production:
1. Update the `baseUrl` in `AuthApiService` to your production API
2. Implement proper error handling based on your API responses
3. Add authentication token handling if required

## Error Scenarios Handled

1. **Network Failures**: Proper error messages with retry options
2. **Validation Errors**: Field-level validation with instant feedback
3. **Image Upload Issues**: Fallback options and clear error messages
4. **API Response Errors**: Detailed error messages from backend
5. **Navigation Issues**: Safe navigation with state preservation

## Customization Options

### 1. Adding New Fields
To add new data fields:
1. Update `RegistrationData` class
2. Add new events/states in `AuthBloc`
3. Update the relevant page forms
4. Modify the `toRegistrationModel()` method

### 2. Changing Validation Rules
Update the validator functions in each page's form fields.

### 3. Modifying API Integration
Update the `AuthApiService` methods to match your backend API contract.

### 4. UI Customization
All pages use the `AppTheme` for consistent styling. Modify theme properties to change the overall appearance.

## Performance Considerations

1. **Image Compression**: Consider implementing image compression before base64 conversion
2. **Pagination**: For large city lists, consider implementing search and pagination
3. **Caching**: Implement local storage for form data persistence
4. **Network Optimization**: Implement retry mechanisms and timeout handling

## Security Considerations

1. **Data Validation**: All inputs are validated both client-side and should be validated server-side
2. **Image Handling**: Implement file type and size validation
3. **API Security**: Use HTTPS and implement proper authentication
4. **Sensitive Data**: Ensure proper handling of personal information and images

This documentation provides a complete overview of the fixed registration flow that ensures data continuity from the first page to the final API submission.