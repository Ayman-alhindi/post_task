import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with TickerProviderStateMixin {
  static const int _otpLength = 5;
  final List<TextEditingController> _otpControllers = List.generate(
    _otpLength,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
        (index) => FocusNode(),
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _phoneNumber;
  RegistrationData? _registrationData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Get phone number and registration data from auth bloc state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is OTPSent) {
        setState(() {
          _phoneNumber = authState.phoneNumber;
          _registrationData = authState.registrationData;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOTPChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOTP() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == _otpLength && _phoneNumber != null) {
      print('DEBUG: Verifying OTP for phone: $_phoneNumber');
      print('DEBUG: Current registration data: $_registrationData');
      context.read<AuthBloc>().add(
        VerifyOTPRequested(
          phoneNumber: _phoneNumber!,
          otp: otp,
        ),
      );
    }
  }

  void _resendOTP() {
    if (_phoneNumber != null && _registrationData != null) {
      if (_registrationData!.isLogin) {
        // For login flow
        context.read<AuthBloc>().add(
          SendLoginOTPRequested(phoneNumber: _phoneNumber!),
        );
      } else {
        // For registration flow
        context.read<AuthBloc>().add(
          CreateAccountRequested(
            phoneNumber: _phoneNumber!,
            driverType: _registrationData!.driverType,
            companyCode: _registrationData!.companyCode,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.getLocalizedString(context, l10n.verify, l10n.verifyEn)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.safePop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          print('DEBUG: BlocListener received state: ${state.runtimeType}');

          if (state is AuthSuccess) {
            print('DEBUG: AuthSuccess received - navigating to home');
            // Both login and profile completion lead here
            context.go('/home');
          } else if (state is OTPVerified) {
            print('DEBUG: OTPVerified received - navigating to complete-profile');
            // Only registration flow continues to complete profile
            context.push('/complete-profile');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is OTPSent) {
            // Update local state when new OTP is sent
            setState(() {
              _phoneNumber = state.phoneNumber;
              _registrationData = state.registrationData;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.getLocalizedString(
                    context,
                    'تم إرسال رمز التحقق مرة أخرى',
                    'Verification code sent again',
                  ),
                ),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    l10n.getLocalizedString(
                      context,
                      'تحقق من رقم الجوال',
                      'Verify Phone Number',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Subtitle with flow indication
                  Text(
                    _registrationData?.isLogin == true
                        ? l10n.getLocalizedString(
                      context,
                      'تم إرسال رمز تسجيل الدخول إلى رقم الجوال الخاص بك',
                      'Login verification code has been sent to your phone number',
                    )
                        : l10n.getLocalizedString(
                      context,
                      'تم إرسال رمز التحقق إلى رقم الجوال الخاص بك',
                      'Verification code has been sent to your phone number',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      _otpLength,
                          (index) => SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: Theme.of(context).textTheme.headlineMedium,
                          onChanged: (value) => _onOTPChanged(value, index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading ? null : _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : Text(
                          l10n.getLocalizedString(
                              context, l10n.verify, l10n.verifyEn),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Resend OTP
                  TextButton(
                    onPressed: _resendOTP,
                    child: Text(
                      l10n.getLocalizedString(
                        context,
                        'إعادة إرسال الرمز',
                        'Resend Code',
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),

                  // Debug info (remove in production)
                  if (_registrationData != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Flow: ${_registrationData!.isLogin ? "Login" : "Registration"}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
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