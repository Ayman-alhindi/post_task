import 'package:flutter/material.dart';

double responsiveValue(BuildContext context, double value) =>
    MediaQuery.of(context).size.width * (value / 375.0);

space10Vertical(BuildContext context) => SizedBox(
      height: responsiveValue(context, 10.0),
    );

space10Horizontal(BuildContext context) => SizedBox(
      width: responsiveValue(context, 10.0),
    );

space20Vertical(BuildContext context) => SizedBox(
      height: responsiveValue(context, 20.0),
    );
