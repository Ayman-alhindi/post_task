import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _companyCodeController = TextEditingController();

  // 0 = Individual, 1 = Company
  int _driverType = 0;

  @override
  void dispose() {
    _mobileController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OTPSent) {
            context.push('/verification', extra: 'register');
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
                  const SizedBox(height: 40),

                  // Logo Section with Dark Background
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Welcome Text
                  Text(
                    l10n.getLocalizedString(
                      context,
                      'إنشاء حساب جديد',
                      'Create New Account',
                    ),
                    style: AppStyles.getTextStyle(
                      context,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.getLocalizedString(
                      context,
                      'أدخل رقم هاتفك لإنشاء حساب جديد',
                      'Enter your phone number to create a new account',
                    ),
                    style: AppStyles.getTextStyle(
                      context,
                      fontSize: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  // Driver Type Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _driverType = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _driverType == 0
                                ? AppTheme.primaryColor
                                : Colors.white,
                            foregroundColor: _driverType == 0
                                ? Colors.white
                                : AppTheme.primaryColor,
                            side: BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _driverType == 0 ? 2 : 0,
                          ),
                          child: Text(
                            l10n.getLocalizedString(
                              context,
                              'سائق مستقل',
                              'Individual Driver',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _driverType = 1;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _driverType == 1
                                ? AppTheme.primaryColor
                                : Colors.white,
                            foregroundColor: _driverType == 1
                                ? Colors.white
                                : AppTheme.primaryColor,
                            side: BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _driverType == 1 ? 2 : 0,
                          ),
                          child: Text(
                            l10n.getLocalizedString(
                              context,
                              'سائق شركة',
                              'Company Driver',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Mobile Number Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.getLocalizedString(
                            context, l10n.mobileNumber, l10n.mobileNumberEn),
                        hintText: l10n.getLocalizedString(
                          context,
                          '05xxxxxxxx',
                          '05xxxxxxxx',
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.phone_outlined,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.getLocalizedString(
                            context,
                            'رقم الهاتف مطلوب',
                            'Phone number is required',
                          );
                        }
                        if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
                          return l10n.getLocalizedString(
                            context,
                            'رقم الهاتف غير صحيح',
                            'Invalid phone number format',
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  // Company Code Field (only if company driver)
                  if (_driverType == 1) ...[
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _companyCodeController,
                        decoration: InputDecoration(
                          labelText: l10n.getLocalizedString(
                            context,
                            'رمز الشركة',
                            'Company Code',
                          ),
                          hintText: l10n.getLocalizedString(
                            context,
                            'أدخل رمز الشركة',
                            'Enter company code',
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.business,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (_driverType == 1) {
                            if (value == null || value.isEmpty) {
                              return l10n.getLocalizedString(
                                context,
                                'رمز الشركة مطلوب',
                                'Company code is required',
                              );
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

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
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                          CreateAccountRequested(
                                            phoneNumber: _mobileController.text,
                                            driverType: _driverType,
                                            companyCode: _driverType == 1
                                                ? _companyCodeController.text
                                                : null,
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
                                      context, l10n.submit, l10n.submitEn),
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
                  const SizedBox(height: 40),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.getLocalizedString(
                          context,
                          'لديك حساب بالفعل؟',
                          'Already have an account?',
                        ),
                        style: AppStyles.getTextStyle(
                          context,
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/login');
                        },
                        child: Text(
                          l10n.getLocalizedString(
                              context, l10n.login, l10n.loginEn),
                          style: AppStyles.getTextStyle(
                            context,
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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