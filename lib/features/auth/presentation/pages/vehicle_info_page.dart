import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import 'transportation_info_page.dart';

class VehicleInfoPage extends StatefulWidget {
  const VehicleInfoPage({super.key});

  @override
  State<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  XFile? _carLicenseImage;
  Uint8List? _carLicenseImageBytes;

  Future<void> _pickCarLicenseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }
      setState(() {
        _carLicenseImage = image;
        if (kIsWeb) {
          _carLicenseImageBytes = bytes;
        }
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final List<String> _carTypes = ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Van'];
  final List<String> _carModels = ['2020', '2021', '2022', '2023', '2024'];
  String? _selectedCarType;
  String? _selectedCarModel;
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _seatsController = TextEditingController();
  final List<XFile> _vehicleImages = [];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (_vehicleImages.length < 5) {
          _vehicleImages.add(image);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _vehicleImages.removeAt(index);
    });
  }

  Future<void> _continueToTransportationInfo() async {
    if (_formKey.currentState!.validate() &&
        _vehicleImages.length >= 3 &&
        _carLicenseImage != null) {
      
      // Convert vehicle images to base64
      List<String> vehicleImagesBase64 = [];
      for (final img in _vehicleImages) {
        vehicleImagesBase64.add(base64Encode(await img.readAsBytes()));
      }

      // Convert car license image to base64
      final carLicenseImageBase64 = base64Encode(await _carLicenseImage!.readAsBytes());

      // Update vehicle data in BLoC
      context.read<AuthBloc>().add(
        VehicleDataUpdated(
          vehicleType: _selectedCarType ?? '',
          vehicleModel: _selectedCarModel ?? '',
          vehicleColor: _colorController.text,
          plateNumber: _plateController.text,
          seats: int.tryParse(_seatsController.text) ?? 0,
          carLicenseImage: carLicenseImageBase64,
          vehicleImages: vehicleImagesBase64,
        ),
      );

      // Navigate to transportation info page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TransportationInfoPage(),
        ),
      );
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).getLocalizedString(
              context,
              'يرجى ملء جميع الحقول ورفع الصور المطلوبة (3 صور على الأقل)',
              'Please fill all fields and upload required images (at least 3 images)',
            ),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _plateController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
            l10n.getLocalizedString(context, 'بيانات المركبة', 'Vehicle Info')),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
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
                  
                  // Car Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCarType,
                    items: _carTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCarType = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                          context, 'نوع المركبة', 'Vehicle Type'),
                      prefixIcon: Icon(Icons.directions_car,
                          color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Car Model Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCarModel,
                    items: _carModels
                        .map((model) => DropdownMenuItem(
                              value: model,
                              child: Text(model),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCarModel = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                          context, 'موديل المركبة', 'Vehicle Model'),
                      prefixIcon: Icon(Icons.calendar_today,
                          color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _colorController,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                          context, 'لون المركبة', 'Vehicle Color'),
                      hintText: l10n.getLocalizedString(
                          context, 'مثال: أبيض', 'e.g. White'),
                      prefixIcon:
                          Icon(Icons.color_lens, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _plateController,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                          context, 'رقم اللوحة', 'Plate Number'),
                      hintText: l10n.getLocalizedString(
                          context, 'مثال: أ ب ج 1234', 'e.g. ABC 1234'),
                      prefixIcon: Icon(Icons.confirmation_number_outlined,
                          color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _seatsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.getLocalizedString(
                          context, 'عدد المقاعد', 'Seat Count'),
                      hintText:
                          l10n.getLocalizedString(context, 'مثال: 4', 'e.g. 4'),
                      prefixIcon:
                          Icon(Icons.event_seat, color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                        : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // Car License Image Upload
                  Text(
                      l10n.getLocalizedString(
                          context, 'صورة استمارة السيارة', 'Car License Photo'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickCarLicenseImage,
                          icon: Icon(Icons.upload_file,
                              color: AppTheme.primaryColor),
                          label: Text(l10n.getLocalizedString(context,
                              'رفع صورة الاستمارة', 'Upload License Photo')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickCarLicenseImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2)),
                          ),
                          child: _carLicenseImage != null
                              ? (kIsWeb
                                  ? (_carLicenseImageBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.memory(
                                            _carLicenseImageBytes!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          ),
                                        )
                                      : null)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_carLicenseImage!.path),
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                                    ))
                              : Center(
                                  child: Icon(Icons.camera_alt,
                                      color: AppTheme.primaryColor, size: 36),
                                ),
                        ),
                      ),
                      if (_carLicenseImage == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            l10n.getLocalizedString(context, 'مطلوب', 'Required'),
                            style:
                                const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                      l10n.getLocalizedString(
                          context, 'صور المركبة', 'Vehicle Images'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _vehicleImages.length < 5 ? _pickImage : null,
                    icon: Icon(Icons.upload_file, color: AppTheme.primaryColor),
                    label: Text(l10n.getLocalizedString(
                        context,
                        'رفع صورة (الحد الأدنى 3، الحد الأقصى 5)',
                        'Upload Image (min 3, max 5)')),
                  ),
                  const SizedBox(height: 8),
                  if (_vehicleImages.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: List.generate(_vehicleImages.length, (index) {
                        final img = _vehicleImages[index];
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? FutureBuilder<Uint8List>(
                                      future: img.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          );
                                        } else {
                                          return const SizedBox(
                                              width: 90,
                                              height: 90,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()));
                                        }
                                      },
                                    )
                                  : Image.file(
                                      File(img.path),
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  if (_vehicleImages.length < 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        l10n.getLocalizedString(
                          context,
                          'يجب رفع 3 صور على الأقل',
                          'At least 3 images required',
                        ),
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 32),
                  
                  Container(
                    height: Localizations.localeOf(context).languageCode == 'ar'
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
                      onPressed: _continueToTransportationInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: Localizations.localeOf(context)
                                      .languageCode ==
                                  'ar'
                              ? 16
                              : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.getLocalizedString(context, 'استمرار', 'Continue'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
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