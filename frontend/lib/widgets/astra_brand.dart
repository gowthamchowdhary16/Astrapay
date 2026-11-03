import 'package:flutter/material.dart';
import '../theme.dart';

class AstraBrand extends StatelessWidget {
  final double logoSize;
  final double textSize;

  const AstraBrand({
    super.key,
    this.logoSize = 50,
    this.textSize = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/astrapay_logo.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
        SizedBox(width: logoSize * 0.20),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'ASTRA',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'pay',
                style: TextStyle(
                  color: AstraTheme.primaryBlue,
                  fontSize: textSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}