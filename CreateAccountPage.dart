import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/styles/app_styles.dart';
import '../bloc/auth_bloc.dart';

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