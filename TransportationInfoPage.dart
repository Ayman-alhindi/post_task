import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/models/registration_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/location_service.dart';

class TransportationInfoPage extends StatefulWidget {
  final RegistrationModel registrationModel;

  const TransportationInfoPage({super.key, required this.registrationModel});

  @override
  State<TransportationInfoPage> createState() => _TransportationInfoPageState();
}

class _TransportationInfoPageState extends State<TransportationInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _districtController = TextEditingController();

  // City dropdown
  String? _selectedCity;

  // Transport type checkboxes (can select multiple)
  bool _isShared = false;
  bool _isPrivate = false;

  // Transport category checkboxes (can select multiple)
  bool _schoolStudents = false;
  bool _universityStudents = false;
  bool _employees = false;

  // Cities list
  final List<Map<String, String>> _cities = [
    {'id': 'riyadh', 'ar': 'الرياض', 'en': 'Riyadh'},
    {'id': 'jeddah', 'ar': 'جدة', 'en': 'Jeddah'},
    {'id': 'dammam', 'ar': 'الدمام', 'en': 'Dammam'},
    {'id': 'makkah', 'ar': 'مكة المكرمة', 'en': 'Makkah'},
    {'id': 'medina', 'ar': 'المدينة المنورة', 'en': 'Medina'},
    {'id': 'taif', 'ar': 'الطائف', 'en': 'Taif'},
    {'id': 'abha', 'ar': 'أبها', 'en': 'Abha'},
    {'id': 'tabuk', 'ar': 'تبوك', 'en': 'Tabuk'},
    {'id': 'hail', 'ar': 'حائل', 'en': 'Hail'},
    {'id': 'jazan', 'ar': 'جازان', 'en': 'Jazan'},
    {'id': 'najran', 'ar': 'نجران', 'en': 'Najran'},
    {'id': 'al_ahsa', 'ar': 'الأحساء', 'en': 'Al Ahsa'},
    {'id': 'al_khobar', 'ar': 'الخبر', 'en': 'Al Khobar'},
    {'id': 'dhahran', 'ar': 'الظهران', 'en': 'Dhahran'},
    {'id': 'al_kharj', 'ar': 'الخرج', 'en': 'Al Kharj'},
    {'id': 'al_qassim', 'ar': 'القصيم', 'en': 'Al Qassim'},
    {'id': 'al_baha', 'ar': 'الباحة', 'en': 'Al Baha'},
    {'id': 'al_jouf', 'ar': 'الجوف', 'en': 'Al Jouf'},
    {
      'id': 'northern_borders',
      'ar': 'الحدود الشمالية',
      'en': 'Northern Borders'
    },
    {'id': 'other', 'ar': 'أخرى', 'en': 'Other'},
  ];

  @override
  void dispose() {
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getLocalizedString(
            context, 'معلومات النقل', 'Transportation Info')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // City Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCity == null
                          ? Colors.grey.withOpacity(0.3)
                          : AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      labelText:
                          l10n.getLocalizedString(context, 'المدينة', 'City'),
                      hintText: l10n.getLocalizedString(
                          context, 'اختر المدينة', 'Select city'),
                      prefixIcon: Icon(Icons.location_city,
                          color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city['id'],
                        child: Text(
                          isArabic ? city['ar']! : city['en']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) {
                      print('City validator called with value: $value');
                      if (value == null || value.isEmpty) {
                        return l10n.getLocalizedString(
                            context, 'مطلوب', 'Required');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // District Field
                TextFormField(
                  controller: _districtController,
                  decoration: InputDecoration(
                    labelText:
                        l10n.getLocalizedString(context, 'الحي', 'District'),
                    hintText: l10n.getLocalizedString(
                        context, 'أدخل الحي', 'Enter district'),
                    prefixIcon:
                        Icon(Icons.location_on, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    print('District validator called with value: $value');
                    return value == null || value.isEmpty
                        ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                        : null;
                  },
                ),
                const SizedBox(height: 24),

                // Transport Type Section
                Text(
                  l10n.getLocalizedString(
                      context, 'نوع النقل', 'Transport Type'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Shared Transport Checkbox
                CheckboxListTile(
                  title: Text(
                      l10n.getLocalizedString(context, 'تشاركي', 'Shared')),
                  value: _isShared,
                  onChanged: (bool? value) {
                    setState(() {
                      _isShared = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppTheme.primaryColor,
                ),

                // Private Transport Checkbox
                CheckboxListTile(
                  title:
                      Text(l10n.getLocalizedString(context, 'خاص', 'Private')),
                  value: _isPrivate,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPrivate = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),

                // Transport Category Section
                Text(
                  l10n.getLocalizedString(
                      context, 'فئة النقل', 'Transport Category'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // School Students Checkbox
                CheckboxListTile(
                  title: Text(l10n.getLocalizedString(
                      context, 'طلبة مدارس', 'School Students')),
                  value: _schoolStudents,
                  onChanged: (bool? value) {
                    setState(() {
                      _schoolStudents = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppTheme.primaryColor,
                ),

                // University Students Checkbox
                CheckboxListTile(
                  title: Text(l10n.getLocalizedString(
                      context, 'طلبة جامعات', 'University Students')),
                  value: _universityStudents,
                  onChanged: (bool? value) {
                    setState(() {
                      _universityStudents = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppTheme.primaryColor,
                ),

                // Employees Checkbox
                CheckboxListTile(
                  title: Text(
                      l10n.getLocalizedString(context, 'موظفين', 'Employees')),
                  value: _employees,
                  onChanged: (bool? value) {
                    setState(() {
                      _employees = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(height: 32),

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
                            : () {
                          print('Create Account button pressed');
                          print(
                              'Form valid: ${_formKey.currentState?.validate()}');
                          print('Shared: $_isShared, Private: $_isPrivate');
                          print(
                              'School: $_schoolStudents, University: $_universityStudents, Employees: $_employees');

                          if (_formKey.currentState!.validate() &&
                              (_isShared || _isPrivate) &&
                              (_schoolStudents ||
                                  _universityStudents ||
                                  _employees)) {
                            // Collect cityId, neighborhoodId, etc.
                            final updatedModel =
                            widget.registrationModel.copyWith(
                              cityId: _cities
                                  .indexWhere((c) => c['id'] == _selectedCity),
                              // Fill the rest as needed:
                              neighborhoodId: 0,
                              longitude: LocationService.longitude ?? 0,
                              latitude: LocationService.latitude ?? 0,
                              role: '',
                              roleId: 0,
                              password: '',
                            );
                            
                            // Print the final model for debugging
                            print('Final Registration Model:');
                            print('Full Name: ${updatedModel.fullName}');
                            print('Email: ${updatedModel.email}');
                            print('Phone: ${updatedModel.phoneNumber}');
                            print('City ID: ${updatedModel.cityId}');
                            print('Driver Type: ${updatedModel.driverDto.isIndependent ? "Individual" : "Company"}');
                            print('Company Code: ${updatedModel.driverDto.companyCode}');
                            print('Vehicle Type: ${updatedModel.vehicleDto.type}');
                            print('Vehicle Model: ${updatedModel.vehicleDto.model}');
                            
                            context
                                .read<AuthBloc>()
                                .add(SubmitRegistrationRequested(updatedModel));
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.getLocalizedString(
                                    context,
                                    'يرجى اختيار نوع النقل وفئة واحدة على الأقل',
                                    'Please select transport type and at least one category')),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
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
                        child: state is AuthLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : Text(
                          l10n.getLocalizedString(
                              context, 'إنشاء حساب', 'Create Account'),
                          style: AppStyles.getTextStyle(
                            context,
                            fontSize: Localizations.localeOf(context)
                                .languageCode ==
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
    );
  }
}