import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class TransportationInfoPage extends StatefulWidget {
  const TransportationInfoPage({super.key});

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

  void _submitRegistration() {
    if (_formKey.currentState!.validate() &&
        (_isShared || _isPrivate) &&
        (_schoolStudents || _universityStudents || _employees)) {
      
      // Get city ID from the selected city
      final cityId = _cities.indexWhere((c) => c['id'] == _selectedCity);
      
      // Submit registration with transportation data
      context.read<AuthBloc>().add(
        SubmitRegistrationRequested(
          cityId: cityId,
          district: _districtController.text,
          isShared: _isShared,
          isPrivate: _isPrivate,
          schoolStudents: _schoolStudents,
          universityStudents: _universityStudents,
          employees: _employees,
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).getLocalizedString(
              context,
              'يرجى ملء جميع الحقول واختيار نوع النقل وفئة واحدة على الأقل',
              'Please fill all fields and select transport type and at least one category',
            ),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

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
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.getLocalizedString(
            context, 'معلومات النقل', 'Transportation Info')),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Show success message and navigate to home
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
            
            // Navigate to home or login screen
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
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

                  // Title
                  Text(
                    l10n.getLocalizedString(
                      context,
                      'معلومات النقل',
                      'Transportation Information',
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
                      'الخطوة الأخيرة - أدخل معلومات النقل',
                      'Final step - Enter transportation information',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _districtController,
                      decoration: InputDecoration(
                        labelText:
                            l10n.getLocalizedString(context, 'الحي', 'District'),
                        hintText: l10n.getLocalizedString(
                            context, 'أدخل الحي', 'Enter district'),
                        prefixIcon:
                            Icon(Icons.location_on, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? l10n.getLocalizedString(context, 'مطلوب', 'Required')
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transport Type Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.getLocalizedString(
                              context, 'نوع النقل', 'Transport Type'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        // Shared Transport Checkbox
                        CheckboxListTile(
                          title: Text(l10n.getLocalizedString(
                              context, 'تشاركي', 'Shared')),
                          subtitle: Text(
                            l10n.getLocalizedString(
                              context,
                              'نقل مشترك مع عدة ركاب',
                              'Shared transport with multiple passengers',
                            ),
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
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
                          title: Text(l10n.getLocalizedString(
                              context, 'خاص', 'Private')),
                          subtitle: Text(
                            l10n.getLocalizedString(
                              context,
                              'نقل خاص مخصص',
                              'Dedicated private transport',
                            ),
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          value: _isPrivate,
                          onChanged: (bool? value) {
                            setState(() {
                              _isPrivate = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transport Category Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          subtitle: Text(
                            l10n.getLocalizedString(
                              context,
                              'نقل طلاب المدارس',
                              'School student transportation',
                            ),
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
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
                          subtitle: Text(
                            l10n.getLocalizedString(
                              context,
                              'نقل طلاب الجامعات',
                              'University student transportation',
                            ),
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
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
                          title: Text(l10n.getLocalizedString(
                              context, 'موظفين', 'Employees')),
                          subtitle: Text(
                            l10n.getLocalizedString(
                              context,
                              'نقل الموظفين والعمال',
                              'Employee and worker transportation',
                            ),
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          value: _employees,
                          onChanged: (bool? value) {
                            setState(() {
                              _employees = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
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
                          onPressed: state is AuthLoading ? null : _submitRegistration,
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
                                  style: const TextStyle(
                                    fontSize: 16,
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
                  const SizedBox(height: 24),

                  // Debug Info - Show current registration data
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final authBloc = context.read<AuthBloc>();
                      final registrationData = authBloc.currentRegistrationData;
                      
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registration Data Summary:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Phone: ${registrationData.phoneNumber ?? "N/A"}'),
                            Text('Name: ${registrationData.fullName ?? "N/A"}'),
                            Text('Email: ${registrationData.email ?? "N/A"}'),
                            Text('Vehicle Type: ${registrationData.vehicleType ?? "N/A"}'),
                            Text('Driver Type: ${registrationData.driverType == 0 ? "Individual" : registrationData.driverType == 1 ? "Company" : "N/A"}'),
                          ],
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