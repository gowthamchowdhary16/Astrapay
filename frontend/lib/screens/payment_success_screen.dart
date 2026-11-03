import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';

class PaymentSuccessScreen
    extends StatelessWidget {
  final double amount;
  final double newBalance;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.newBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            25,
            30,
            25,
            25,
          ),

          child: Column(
            children: [
              const AstraBrand(
                logoSize: 48,
                textSize: 25,
              ),

              const Spacer(),

              // Success icon
              Container(
                width: 100,
                height: 100,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE4F9F0),
                  shape:
                      BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check_rounded,
                  color:
                      Color(0xFF0AA875),
                  size: 58,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Money Added Successfully!',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'The money has been added to your AstraPay wallet.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // Amount
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        AstraTheme.borderBlue,
                  ),
                ),

                child: Column(
                  children: [
                    const Text(
                      'Amount Added',
                      style: TextStyle(
                        color:
                            AstraTheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '+ ₹${amount.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF00A875),
                        fontSize: 30,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 17),

                    const Divider(),

                    const SizedBox(height: 13),

                    const Text(
                      'Updated Wallet Balance',
                      style: TextStyle(
                        color:
                            AstraTheme.secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '₹${newBalance.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        color:
                            AstraTheme.textBlue,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Return new balance to Add Money screen.
                    Navigator.pop(
                      context,
                      newBalance,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AstraTheme.primaryBlue,
                    foregroundColor:
                        Colors.white,
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Wallet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}