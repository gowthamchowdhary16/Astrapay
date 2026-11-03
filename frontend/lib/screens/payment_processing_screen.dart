import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'payment_success_screen.dart';

class PaymentProcessingScreen
    extends StatefulWidget {
  final double amount;
  final double currentBalance;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.currentBalance,
  });

  @override
  State<PaymentProcessingScreen>
      createState() =>
          _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PaymentSuccessScreen(
              amount: widget.amount,
              newBalance:
                  widget.currentBalance +
                      widget.amount,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(30),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                const AstraBrand(
                  logoSize: 65,
                  textSize: 30,
                ),

                const SizedBox(height: 45),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color:
                        AstraTheme.lightBlue,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Padding(
                    padding:
                        EdgeInsets.all(25),
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 3,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Processing Payment',
                  style: TextStyle(
                    color:
                        AstraTheme.textBlue,
                    fontSize: 23,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Adding ₹${widget.amount.toStringAsFixed(2)} to your wallet',
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    color:
                        AstraTheme.secondaryText,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Please wait...',
                  style: TextStyle(
                    color:
                        AstraTheme.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}