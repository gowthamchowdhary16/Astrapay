import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';

class SecurityVerificationScreen
    extends StatefulWidget {
  final double amount;
  final double currentBalance;
  final double dailyLimit;
  final double spentToday;
  final String recipient;
  final String paymentMethod;

  const SecurityVerificationScreen({
    super.key,
    required this.amount,
    required this.currentBalance,
    required this.dailyLimit,
    required this.spentToday,
    required this.recipient,
    required this.paymentMethod,
  });

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState
    extends State<SecurityVerificationScreen> {
  final LocalAuthentication auth =
      LocalAuthentication();

  final TextEditingController passwordController =
      TextEditingController();

  bool verifyingFingerprint = false;
  bool showPassword = false;
  bool passwordError = false;

  // Demo password.
  // Later this will be replaced by the user's
  // securely stored wallet PIN/password.
  static const String demoPassword = '1234';

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // FINGERPRINT / BIOMETRIC
  // ==========================================================

  Future<void> verifyFingerprint() async {
    if (verifyingFingerprint) return;

    setState(() {
      verifyingFingerprint = true;
    });

    try {
      final bool canCheck =
          await auth.canCheckBiometrics;

      final bool supported =
          await auth.isDeviceSupported();

      if (!canCheck && !supported) {
        if (!mounted) return;

        setState(() {
          verifyingFingerprint = false;
          showPassword = true;
        });

        _showMessage(
          'Fingerprint is not available. Use your password.',
        );

        return;
      }

   final bool authenticated =
    await auth.authenticate(
  localizedReason:
      'Verify your identity to confirm this payment.',
  biometricOnly: false,
  persistAcrossBackgrounding: true,
);

      if (!mounted) return;

      setState(() {
        verifyingFingerprint = false;
      });

      if (authenticated) {
        _verificationSuccessful();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        verifyingFingerprint = false;
      });

      _showMessage(
        'Biometric verification failed. You can use your password.',
      );

      setState(() {
        showPassword = true;
      });
    }
  }

  // ==========================================================
  // PASSWORD
  // ==========================================================

  void verifyPassword() {
    final password =
        passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        passwordError = true;
      });

      return;
    }

    if (password != demoPassword) {
      setState(() {
        passwordError = true;
      });

      _showMessage(
        'Incorrect password.',
      );

      return;
    }

    _verificationSuccessful();
  }

  // ==========================================================
  // SUCCESS
  // ==========================================================

  void _verificationSuccessful() {
    Navigator.pop(
      context,
      true,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor:
            AstraTheme.textBlue,

        title: const Text(
          'Security Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [
              const AstraBrand(
                logoSize: 48,
                textSize: 25,
              ),

              const SizedBox(height: 35),

              // Security icon
              Container(
                width: 92,
                height: 92,

                decoration:
                    const BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  shape:
                      BoxShape.circle,
                ),

                child: const Icon(
                  Icons.shield_outlined,
                  color:
                      AstraTheme.primaryBlue,
                  size: 48,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Verify Payment',
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Confirm your identity before sending money.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 25),

              // Payment summary
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(18),

                decoration:
                    BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border:
                      Border.all(
                    color:
                        AstraTheme.borderBlue,
                  ),
                ),

                child: Column(
                  children: [
                    const Text(
                      'Payment Amount',
                      style:
                          TextStyle(
                        color:
                            AstraTheme.secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        color:
                            AstraTheme.primaryBlue,
                        fontSize: 29,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Divider(),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'To',
                          style:
                              TextStyle(
                            color:
                                AstraTheme.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            widget.recipient,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              color:
                                  AstraTheme.textBlue,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // FINGERPRINT
              // =================================================

              GestureDetector(
                onTap:
                    verifyFingerprint,

                child: Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(18),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    border:
                        Border.all(
                      color:
                          AstraTheme.primaryBlue,
                      width: 1.4,
                    ),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration:
                            const BoxDecoration(
                          color:
                              AstraTheme.lightBlue,
                          shape:
                              BoxShape.circle,
                        ),

                        child:
                            verifyingFingerprint
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(
                                      14,
                                    ),
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                      color:
                                          AstraTheme.primaryBlue,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .fingerprint_rounded,
                                    color:
                                        AstraTheme.primaryBlue,
                                    size: 30,
                                  ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Use Fingerprint',
                              style:
                                  TextStyle(
                                color:
                                    AstraTheme.textBlue,
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Verify quickly using your device biometric',
                              style:
                                  TextStyle(
                                color:
                                    AstraTheme.secondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        color:
                            AstraTheme.primaryBlue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // OR
              Row(
                children: [
                  const Expanded(
                    child: Divider(),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'OR',
                      style:
                          TextStyle(
                        color:
                            AstraTheme.secondaryText,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // =================================================
              // PASSWORD
              // =================================================

              GestureDetector(
                onTap: () {
                  setState(() {
                    showPassword =
                        !showPassword;
                  });
                },

                child: Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(17),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    border:
                        Border.all(
                      color:
                          AstraTheme.borderBlue,
                    ),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,

                        decoration:
                            const BoxDecoration(
                          color:
                              AstraTheme.lightBlue,
                          shape:
                              BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons
                              .lock_outline_rounded,
                          color:
                              AstraTheme.primaryBlue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Use Password',
                              style:
                                  TextStyle(
                                color:
                                    AstraTheme.textBlue,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Enter your wallet password',
                              style:
                                  TextStyle(
                                color:
                                    AstraTheme.secondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        showPassword
                            ? Icons
                                .keyboard_arrow_up_rounded
                            : Icons
                                .keyboard_arrow_down_rounded,
                        color:
                            AstraTheme.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),

              if (showPassword) ...[
                const SizedBox(height: 12),

                TextField(
                  controller:
                      passwordController,
                  obscureText: true,
                  keyboardType:
                      TextInputType.number,

                  onChanged: (_) {
                    setState(() {
                      passwordError = false;
                    });
                  },

                  decoration:
                      InputDecoration(
                    labelText:
                        'Wallet Password / PIN',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                      color:
                          AstraTheme.primaryBlue,
                    ),

                    errorText:
                        passwordError
                            ? 'Incorrect password'
                            : null,

                    filled: true,

                    fillColor:
                        const Color(
                      0xFFF6F9FF,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AstraTheme.borderBlue,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AstraTheme.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child:
                      ElevatedButton(
                    onPressed:
                        verifyPassword,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AstraTheme.primaryBlue,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),

                    child:
                        const Text(
                      'Verify Password',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              const Text(
                'Your security credentials are never shared with AstraPay.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}