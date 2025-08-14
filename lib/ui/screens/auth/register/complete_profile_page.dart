import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/models/registration_model.dart';
import 'vehicle_info_page.dart';
import '../../../../core/services/location_service.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  String? _phoneNumber;
  String? _companyCode;
  XFile? _idImage;
  XFile? _licenseImage;
  XFile? _driverPhoto;
  Uint8List? _driverPhotoBytes;
  int? _driverType;

  Future<void> _pickDriverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }
      setState(() {
        _driverPhoto = image;
        if (kIsWeb) {
          _driverPhotoBytes = bytes;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Get phone number and registration data from auth bloc state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is OTPVerified) {
        setState(() {
          _phoneNumber = authState.phoneNumber;
          _driverType = authState.registrationData.driverType;
          _companyCode = authState.registrationData.companyCode;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  Future<void> _pickIdImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _idImage = image;
      });
    }
  }

  Future<void> _pickLicenseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _licenseImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.getLocalizedString(
            context,
            'إكمال الملف الشخصي',
            'Complete Profile',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.safePop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Welcome Text
                  Text(
                    l10n.getLocalizedString(
                      context,
                      'أكمل ملفك الشخصي',
                      'Complete Your Profile',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.getLocalizedString(
                      context,
                      'أدخل معلوماتك الشخصية لإكمال التسجيل',
                      'Enter your personal information to complete registration',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Driver Photo Upload
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickDriverPhoto,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.1,
                            ),
                            backgroundImage: _driverPhoto != null
                                ? (kIsWeb
                                    ? (_driverPhotoBytes != null
                                        ? MemoryImage(_driverPhotoBytes!)
                                        : null)
                                    : FileImage(File(_driverPhoto!.path))
                                        as ImageProvider)
                                : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  ),
                            child: _driverPhoto == null
                                ? Icon(
                                    Icons.camera_alt,
                                    color: AppTheme.primaryColor,
                                    size: 32,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _pickDriverPhoto,
                          icon: Icon(
                            Icons.upload_file,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            l10n.getLocalizedString(
                              context,
                              'رفع صورة السائق',
                              'Upload Driver Photo',
                            ),
                          ),
                        ),
                        if (_driverPhoto == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              l10n.getLocalizedString(
                                context,
                                'مطلوب',
                                'Required',
                              ),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                        context,
                        l10n.name,
                        l10n.nameEn,
                      ),
                      hintText: l10n.getLocalizedString(
                        context,
                        'أدخل اسمك الكامل',
                        'Enter your full name',
                      ),
                      prefixIcon: Icon(
                        Icons.person_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getLocalizedString(
                          context,
                          'الاسم مطلوب',
                          'Name is required',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                        context,
                        l10n.email,
                        l10n.emailEn,
                      ),
                      hintText: l10n.getLocalizedString(
                        context,
                        'أدخل بريدك الإلكتروني',
                        'Enter your email',
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getLocalizedString(
                          context,
                          'البريد الإلكتروني مطلوب',
                          'Email is required',
                        );
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return l10n.getLocalizedString(
                          context,
                          'البريد الإلكتروني غير صحيح',
                          'Invalid email format',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // National ID Field
                  TextFormField(
                    controller: _nationalIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                        context,
                        'رقم الهوية',
                        'National ID Number',
                      ),
                      hintText: l10n.getLocalizedString(
                        context,
                        'أدخل رقم الهوية',
                        'Enter your national ID number',
                      ),
                      prefixIcon: Icon(
                        Icons.credit_card,
                        color: AppTheme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getLocalizedString(
                          context,
                          'رقم الهوية مطلوب',
                          'National ID is required',
                        );
                      }
                      if (value.length < 10) {
                        return l10n.getLocalizedString(
                          context,
                          'رقم الهوية غير صحيح',
                          'Invalid national ID',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ID Image Upload
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickIdImage,
                          icon: Icon(
                            Icons.upload_file,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            l10n.getLocalizedString(
                              context,
                              'رفع صورة الهوية',
                              'Upload ID Image',
                            ),
                          ),
                        ),
                      ),
                      if (_idImage != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  if (_idImage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Text(
                        l10n.getLocalizedString(context, 'مطلوب', 'Required'),
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Driver License Number
                  TextFormField(
                    controller: _licenseNumberController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                        context,
                        'رقم رخصة القيادة',
                        'Driver License Number',
                      ),
                      hintText: l10n.getLocalizedString(
                        context,
                        'أدخل رقم الرخصة',
                        'Enter your license number',
                      ),
                      prefixIcon: Icon(
                        Icons.confirmation_number_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getLocalizedString(
                          context,
                          'رقم الرخصة مطلوب',
                          'License number is required',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // License Expiry Date
                  TextFormField(
                    controller: _licenseExpiryController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                        context,
                        'تاريخ انتهاء الرخصة',
                        'License Expiry Date',
                      ),
                      hintText: l10n.getLocalizedString(
                        context,
                        'اختر تاريخ الانتهاء',
                        'Select expiry date',
                      ),
                      prefixIcon: Icon(
                        Icons.date_range,
                        color: AppTheme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _licenseExpiryController.text =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.getLocalizedString(
                          context,
                          'تاريخ الانتهاء مطلوب',
                          'Expiry date is required',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // License Image Upload
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickLicenseImage,
                          icon: Icon(
                            Icons.upload_file,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            l10n.getLocalizedString(
                              context,
                              'رفع صورة الرخصة',
                              'Upload License Image',
                            ),
                          ),
                        ),
                      ),
                      if (_licenseImage != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  if (_licenseImage == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Text(
                        l10n.getLocalizedString(context, 'مطلوب', 'Required'),
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Submit Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Container(
                        height:
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 64
                                : 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate() &&
                                      _phoneNumber != null &&
                                      _idImage != null &&
                                      _licenseImage != null &&
                                      _driverPhoto != null &&
                                      _driverType != null) {
                                    final driverDto = DriverDto(
                                      id: 0,
                                      licenseNumber:
                                          _licenseNumberController.text,
                                      isIndependent: _driverType == 0,
                                      companyCode: _companyCode ?? '',
                                      idNumber: _nationalIdController.text,
                                      idImage: base64Encode(
                                          await _idImage!.readAsBytes()),
                                      licenseImage: base64Encode(
                                          await _licenseImage!.readAsBytes()),
                                    );

                                    final vehicleDto = VehicleDto(
                                      id: 0,
                                      type: 0,
                                      model: '',
                                      color: '',
                                      plateNumber: '',
                                      seats: 0,
                                      nameAr: '',
                                      images: '',
                                    );

                                    final registrationModel = RegistrationModel(
                                      fullName: _nameController.text,
                                      email: _emailController.text,
                                      role: '',
                                      roleId: 0,
                                      cityId: 0,
                                      neighborhoodId: 0,
                                      longitude: LocationService.longitude ?? 0,
                                      latitude: LocationService.latitude ?? 0,
                                      password: '',
                                      phoneNumber: _phoneNumber!,
                                      driverDto: driverDto,
                                      vehicleDto: vehicleDto,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VehicleInfoPage(
                                          registrationModel: registrationModel,
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: Localizations.localeOf(
                                        context,
                                      ).languageCode ==
                                      'ar'
                                  ? 16
                                  : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.getLocalizedString(
                                    context,
                                    'متابعة', // Arabic for Continue
                                    'Continue',
                                  ),
                                  style: TextStyle(
                                    fontSize: Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'ar'
                                        ? 16
                                        : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}