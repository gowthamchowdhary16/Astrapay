import 'dart:async';

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'face_verification_screen.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  final String studentMobile;
  final String parentMobile;

  const AadhaarVerificationScreen({
    super.key,
    required this.studentMobile,
    required this.parentMobile,
  });

  @override
  State<AadhaarVerificationScreen> createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState
    extends State<AadhaarVerificationScreen> {
  final TextEditingController aadhaarController =
      TextEditingController();

  final List<TextEditingController> otpControllers =
      List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> otpFocusNodes =
      List.generate(
    6,
    (_) => FocusNode(),
  );

  bool otpSent = false;
  bool otpVerified = false;
  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool resendEnabled = false;

  int countdown = 60;
  Timer? timer;

  @override
  void dispose() {
    aadhaarController.dispose();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in otpFocusNodes) {
      node.dispose();
    }

    timer?.cancel();

    super.dispose();
  }

  void startTimer() {
    timer?.cancel();

    setState(() {
      countdown = 60;
      resendEnabled = false;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });
        } else {
          setState(() {
            resendEnabled = true;
          });

          timer.cancel();
        }
      },
    );
  }

  Future<void> sendOtp() async {
    final aadhaar =
        aadhaarController.text.replaceAll(' ', '');

    if (aadhaar.length != 12) {
      _showMessage(
        'Enter a valid 12-digit Aadhaar number.',
      );
      return;
    }

    setState(() {
      isSendingOtp = true;
    });

    // TODO:
    // Connect this to your authorized Aadhaar
    // KYC/eKYC provider.

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    setState(() {
      isSendingOtp = false;
      otpSent = true;
    });

    startTimer();

    _showMessage(
      'OTP request sent to the Aadhaar-linked mobile number.',
    );

    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (mounted) {
          otpFocusNodes.first.requestFocus();
        }
      },
    );
  }

  Future<void> resendOtp() async {
    if (!resendEnabled) return;

    for (final controller in otpControllers) {
      controller.clear();
    }

    await sendOtp();
  }

  Future<void> verifyOtp() async {
    final otp =
        otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      _showMessage(
        'Enter the 6-digit OTP.',
      );
      return;
    }

    setState(() {
      isVerifyingOtp = true;
    });

    // TODO:
    // Connect to authorized Aadhaar KYC provider.

    await Future.delayed(
      const Duration(milliseconds: 800),
    );

    setState(() {
      isVerifyingOtp = false;
      otpVerified = true;
    });

    timer?.cancel();

    _showMessage(
      'Aadhaar verification successful.',
    );

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    // IMPORTANT:
    // After Aadhaar OTP verification,
    // go to Face Verification.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const FaceVerificationScreen(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget otpSection() {
    if (!otpSent) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),

        const Text(
          'Enter Aadhaar OTP',
          style: TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) {
              return SizedBox(
                width: 45,
                height: 54,
                child: TextField(
                  controller:
                      otpControllers[index],
                  focusNode:
                      otpFocusNodes[index],
                  keyboardType:
                      TextInputType.number,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AstraTheme.textBlue,
                  ),
                  decoration:
                      InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AstraTheme
                        .lightBlue
                        .withOpacity(0.55),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
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
                        12,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            AstraTheme.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty &&
                        index < 5) {
                      otpFocusNodes[index + 1]
                          .requestFocus();
                    }

                    if (value.isEmpty &&
                        index > 0) {
                      otpFocusNodes[index - 1]
                          .requestFocus();
                    }
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: resendEnabled
              ? TextButton(
                  onPressed: resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color:
                          AstraTheme.primaryBlue,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                )
              : Text(
                  'Resend OTP in 00:${countdown.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color:
                        AstraTheme.primaryBlue,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
        ),

        const SizedBox(height: 5),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:
                isVerifyingOtp
                    ? null
                    : verifyOtp,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AstraTheme.primaryBlue,
              foregroundColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(17),
              ),
            ),
            child: isVerifyingOtp
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : const Text(
                    'Verify Aadhaar OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            45,
            20,
            45,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const AstraBrand(
                logoSize: 46,
                textSize: 24,
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  _stepCircle('1', true),
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                  ),
                  _stepCircle('2', true),
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                  ),
                  _stepCircle('3', true),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Aadhaar Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AstraTheme.textBlue,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Verify the student Aadhaar to continue.',
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Student Aadhaar Number',
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller:
                    aadhaarController,
                keyboardType:
                    TextInputType.number,
                maxLength: 12,
                enabled: !otpVerified,
                decoration:
                    InputDecoration(
                  counterText: '',
                  hintText:
                      'Enter 12-digit Aadhaar number',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color:
                        AstraTheme.primaryBlue,
                  ),
                  filled: true,
                  fillColor: AstraTheme
                      .lightBlue
                      .withOpacity(0.55),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      17,
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
                      17,
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

              const SizedBox(height: 14),

              if (!otpSent)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        isSendingOtp
                            ? null
                            : sendOtp,
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
                          17,
                        ),
                      ),
                    ),
                    child: isSendingOtp
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                  ),
                ),

              otpSection(),

              if (otpVerified) ...[
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFFEAF9F1),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aadhaar verified successfully.',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                  border: Border.all(
                    color:
                        AstraTheme.borderBlue,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The OTP is sent only to the mobile number linked with the Aadhaar record.',
                        style: TextStyle(
                          color:
                              AstraTheme.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'SAFE PAYMENTS FOR THE NEXT GENERATION',
                  style: TextStyle(
                    color:
                        AstraTheme.secondaryText,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCircle(
    String number,
    bool active,
  ) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AstraTheme.primaryBlue
            : AstraTheme.lightBlue,
        border: Border.all(
          color: active
              ? AstraTheme.primaryBlue
              : AstraTheme.borderBlue,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: TextStyle(
          color: active
              ? Colors.white
              : AstraTheme.textBlue,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}