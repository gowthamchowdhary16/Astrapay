import 'dart:async';

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'parent_screen.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends State<StudentRegistrationScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController mobileController =
      TextEditingController();

  final TextEditingController dobController =
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
    nameController.dispose();
    mobileController.dispose();
    dobController.dispose();

    for (final controller in otpControllers) {
      controller.dispose();
    }

    for (final node in otpFocusNodes) {
      node.dispose();
    }

    timer?.cancel();

    super.dispose();
  }

  // ============================================================
  // OTP TIMER
  // ============================================================

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

  // ============================================================
  // SEND STUDENT OTP
  // ============================================================

  Future<void> sendOtp() async {
    final mobile =
        mobileController.text.trim();

    if (mobile.length != 10) {
      _showMessage(
        'Enter a valid 10-digit mobile number.',
      );
      return;
    }

    setState(() {
      isSendingOtp = true;
    });

    // ----------------------------------------------------------
    // TODO:
    // Connect this to your FastAPI endpoint:
    //
    // POST /auth/send-otp
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      isSendingOtp = false;
      otpSent = true;
      otpVerified = false;
    });

    startTimer();

    _showMessage(
      'OTP sent to your mobile number.',
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

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> resendOtp() async {
    if (!resendEnabled) {
      return;
    }

    for (final controller in otpControllers) {
      controller.clear();
    }

    await sendOtp();
  }

  // ============================================================
  // VERIFY STUDENT OTP
  // ============================================================

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

    // ----------------------------------------------------------
    // TODO:
    // Connect this to:
    //
    // POST /auth/verify-otp
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      isVerifyingOtp = false;
      otpVerified = true;
    });

    timer?.cancel();

    _showMessage(
      'Student mobile number verified.',
    );

    // IMPORTANT:
    // Do NOT navigate to ParentScreen here.
    //
    // The user must press Continue manually.
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectDateOfBirth() async {
    final DateTime? selectedDate =
        await showDatePicker(
      context: context,

      // Initial date shown by calendar.
      initialDate: DateTime(2008, 1, 1),

      // Reasonable DOB range for this student/minor flow.
      firstDate: DateTime(2000, 1, 1),

      // Cannot select a future DOB.
      lastDate: DateTime.now(),

      helpText: 'Select Date of Birth',

      cancelText: 'Cancel',

      confirmText: 'Select',

      builder: (
        BuildContext context,
        Widget? child,
      ) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(
              primary:
                  AstraTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface:
                  AstraTheme.textBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) {
      return;
    }

    final String day =
        selectedDate.day
            .toString()
            .padLeft(2, '0');

    final String month =
        selectedDate.month
            .toString()
            .padLeft(2, '0');

    final String year =
        selectedDate.year.toString();

    setState(() {
      dobController.text =
          '$day/$month/$year';
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // NORMAL INPUT FIELD
  // ============================================================

  Widget buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration:
              InputDecoration(
            hintText: hint,

            prefixIcon: Icon(
              icon,
              color:
                  AstraTheme.primaryBlue,
            ),

            filled: true,

            fillColor: AstraTheme
                .lightBlue
                .withOpacity(0.55),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),

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
      ],
    );
  }

  // ============================================================
  // DATE OF BIRTH FIELD
  // ============================================================

  Widget buildDateOfBirthField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: dobController,

          // User cannot type manually.
          readOnly: true,

          // Open calendar when tapped.
          onTap: selectDateOfBirth,

          decoration:
              InputDecoration(
            hintText:
                'DD/MM/YYYY',

            prefixIcon:
                const Icon(
              Icons.calendar_month_outlined,
              color:
                  AstraTheme.primaryBlue,
            ),

            suffixIcon:
                const Icon(
              Icons.keyboard_arrow_down,
              color:
                  AstraTheme.primaryBlue,
            ),

            filled: true,

            fillColor: AstraTheme
                .lightBlue
                .withOpacity(0.55),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),

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
      ],
    );
  }

  // ============================================================
  // OTP SECTION
  // ============================================================

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
          'Enter OTP',
          style: TextStyle(
            color:
                AstraTheme.textBlue,
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children:
              List.generate(
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

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
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
                        .withOpacity(
                          0.55,
                        ),

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

                  onChanged:
                      (value) {
                    if (value.isNotEmpty &&
                        index < 5) {
                      otpFocusNodes[
                              index + 1]
                          .requestFocus();
                    }

                    if (value.isEmpty &&
                        index > 0) {
                      otpFocusNodes[
                              index - 1]
                          .requestFocus();
                    }
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // RESEND TIMER
        // ------------------------------------------------------

        Center(
          child: resendEnabled
              ? TextButton(
                  onPressed:
                      resendOtp,
                  child:
                      const Text(
                    'Resend OTP',
                    style:
                        TextStyle(
                      color:
                          AstraTheme
                              .primaryBlue,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                )
              : Text(
                  'Resend OTP in 00:${countdown.toString().padLeft(2, '0')}',
                  style:
                      const TextStyle(
                    color:
                        AstraTheme
                            .primaryBlue,
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
        ),

        const SizedBox(height: 5),

        // ------------------------------------------------------
        // VERIFY OTP
        // ------------------------------------------------------

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

              elevation: 3,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
              ),
            ),

            child: isVerifyingOtp
                ? const CircularProgressIndicator(
                    color:
                        Colors.white,
                    strokeWidth: 2,
                  )
                : const Text(
                    'Verify OTP',
                    style:
                        TextStyle(
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

  // ============================================================
  // VERIFIED CARD
  // ============================================================

  Widget verifiedCard() {
    return Container(
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
              'Student mobile number verified successfully.',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP CIRCLE
  // ============================================================

  Widget _stepCircle(
    String number,
    bool active,
  ) {
    return Container(
      width: 34,
      height: 34,

      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,

        color: active
            ? AstraTheme.primaryBlue
            : AstraTheme.lightBlue,

        border:
            Border.all(
          color: active
              ? AstraTheme.primaryBlue
              : AstraTheme.borderBlue,
        ),
      ),

      alignment:
          Alignment.center,

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

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      body: SafeArea(
        child:
            SingleChildScrollView(
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
              // ------------------------------------------------
              // ASTRApay BRAND
              // ------------------------------------------------

              const AstraBrand(
                logoSize: 46,
                textSize: 24,
              ),

              const SizedBox(
                height: 25,
              ),

              // ------------------------------------------------
              // PROGRESS
              // ------------------------------------------------

              Row(
                children: [
                  _stepCircle(
                    '1',
                    true,
                  ),

                  Expanded(
                    child:
                        Container(
                      height: 2,
                      color:
                          AstraTheme
                              .primaryBlue,
                    ),
                  ),

                  _stepCircle(
                    '2',
                    false,
                  ),

                  Expanded(
                    child:
                        Container(
                      height: 2,
                      color:
                          AstraTheme
                              .borderBlue,
                    ),
                  ),

                  _stepCircle(
                    '3',
                    false,
                  ),
                ],
              ),

              const SizedBox(
                height: 32,
              ),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------

              const Text(
                'Student (Minor) Details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AstraTheme.textBlue,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Create your AstraPay wallet securely.',
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 15,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // ------------------------------------------------
              // FULL NAME
              // ------------------------------------------------

              buildField(
                label:
                    'Full Name',
                hint:
                    'Enter your full name',
                icon:
                    Icons.person_outline,
                controller:
                    nameController,
              ),

              const SizedBox(
                height: 20,
              ),

              // ------------------------------------------------
              // MOBILE NUMBER
              // ------------------------------------------------

              buildField(
                label:
                    'Mobile Number',
                hint:
                    '10-digit mobile number',
                icon:
                    Icons.phone_outlined,
                controller:
                    mobileController,
                keyboardType:
                    TextInputType.phone,
                enabled:
                    !otpVerified,
              ),

              const SizedBox(
                height: 14,
              ),

              // ------------------------------------------------
              // SEND OTP
              // ------------------------------------------------

              if (!otpSent)
                SizedBox(
                  width:
                      double.infinity,
                  height: 54,

                  child:
                      ElevatedButton(
                    onPressed:
                        isSendingOtp
                            ? null
                            : sendOtp,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AstraTheme
                              .primaryBlue,
                      foregroundColor:
                          Colors.white,
                      elevation: 3,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                      ),
                    ),

                    child:
                        isSendingOtp
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth:
                                    2,
                              )
                            : const Text(
                                'Send OTP',
                                style:
                                    TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                  ),
                ),

              // ------------------------------------------------
              // OTP
              // ------------------------------------------------

              otpSection(),

              // ------------------------------------------------
              // VERIFIED
              // ------------------------------------------------

              if (otpVerified) ...[
                const SizedBox(
                  height: 15,
                ),

                verifiedCard(),
              ],

              const SizedBox(
                height: 22,
              ),

              // ------------------------------------------------
              // DATE OF BIRTH
              // ------------------------------------------------

              buildDateOfBirthField(),

              const SizedBox(
                height: 24,
              ),

              // ------------------------------------------------
              // SECURITY CARD
              // ------------------------------------------------

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      AstraTheme.lightBlue,

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

                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color:
                          AstraTheme
                              .primaryBlue,
                    ),

                    SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        'Your information is securely protected and used only for account verification.',
                        style:
                            TextStyle(
                          color:
                              AstraTheme
                                  .secondaryText,
                          fontSize:
                              12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ------------------------------------------------
              // CONTINUE
              //
              // IMPORTANT:
              // Only appears after OTP verification.
              // ------------------------------------------------

              if (otpVerified)
                SizedBox(
                  width:
                      double.infinity,
                  height: 54,

                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ParentScreen(
                            studentMobile:
                                mobileController
                                    .text
                                    .trim(),
                          ),
                        ),
                      );
                    },

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AstraTheme
                              .primaryBlue,
                      foregroundColor:
                          Colors.white,
                      elevation: 3,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          17,
                        ),
                      ),
                    ),

                    child:
                        const Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        Text(
                          'Continue',
                          style:
                              TextStyle(
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        SizedBox(
                          width: 8,
                        ),

                        Icon(
                          Icons
                              .arrow_forward,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(
                height: 20,
              ),

              // ------------------------------------------------
              // FOOTER
              // ------------------------------------------------

              const Center(
                child: Text(
                  'SAFE PAYMENTS FOR THE NEXT GENERATION',
                  style:
                      TextStyle(
                    color:
                        AstraTheme
                            .secondaryText,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing:
                        1.2,
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