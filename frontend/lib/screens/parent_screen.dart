import 'dart:async';

import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'aadhaar_verification_screen.dart';

class ParentScreen extends StatefulWidget {
  final String studentMobile;

  const ParentScreen({
    super.key,
    required this.studentMobile,
  });

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final TextEditingController parentNameController =
      TextEditingController();

  final TextEditingController parentMobileController =
      TextEditingController();

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool otpSent = false;
  bool otpVerified = false;
  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool resendEnabled = false;
  bool accepted = false;

  int countdown = 60;
  Timer? timer;

  String relationship = "Father";

  @override
  void dispose() {
    parentNameController.dispose();
    parentMobileController.dispose();

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

  bool validateParentMobile() {
    final parentMobile =
        parentMobileController.text.trim();

    if (parentMobile.length != 10) {
      _showMessage(
        "Enter a valid 10-digit parent mobile number.",
      );
      return false;
    }

    if (parentMobile == widget.studentMobile) {
      _showMessage(
        "Student and parent mobile numbers cannot be the same.",
      );
      return false;
    }

    return true;
  }

  Future<void> sendOtp() async {
    if (!validateParentMobile()) return;

    setState(() {
      isSendingOtp = true;
    });

    // TODO:
    // Backend should also validate this rule.
    //
    // POST /auth/send-parent-otp

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    setState(() {
      isSendingOtp = false;
      otpSent = true;
    });

    startTimer();

    _showMessage(
      "OTP sent to parent mobile number.",
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
      _showMessage("Enter the 6-digit OTP.");
      return;
    }

    if (!accepted) {
      _showMessage(
        "Please confirm the parent information.",
      );
      return;
    }

    setState(() {
      isVerifyingOtp = true;
    });

    // TODO:
    // POST /auth/verify-parent-otp

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    setState(() {
      isVerifyingOtp = false;
      otpVerified = true;
    });

    timer?.cancel();

    _showMessage(
      "Parent mobile number verified.",
    );

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AadhaarVerificationScreen(
          studentMobile: widget.studentMobile,
          parentMobile:
              parentMobileController.text.trim(),
        ),
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

  Widget buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: AstraTheme.primaryBlue,
            ),
            filled: true,
            fillColor:
                AstraTheme.lightBlue.withOpacity(0.55),
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AstraTheme.borderBlue,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AstraTheme.primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
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
          "Enter OTP",
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
                    counterText: "",
                    filled: true,
                    fillColor: AstraTheme
                        .lightBlue
                        .withOpacity(0.55),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
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
                              12),
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
                    "Resend OTP",
                    style: TextStyle(
                      color:
                          AstraTheme.primaryBlue,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                )
              : Text(
                  "Resend OTP in 00:${countdown.toString().padLeft(2, '0')}",
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
                    "Verify OTP",
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
                  _stepCircle("1", true),
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                  ),
                  _stepCircle("2", true),
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          AstraTheme.borderBlue,
                    ),
                  ),
                  _stepCircle("3", false),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                "Parent / Guardian Details",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AstraTheme.textBlue,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Add your parent or guardian information.",
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              buildField(
                label:
                    "Parent / Guardian Name",
                hint:
                    "Enter parent full name",
                icon:
                    Icons.person_outline,
                controller:
                    parentNameController,
              ),

              const SizedBox(height: 20),

              buildField(
                label:
                    "Parent Mobile Number",
                hint:
                    "10-digit mobile number",
                icon:
                    Icons.phone_outlined,
                controller:
                    parentMobileController,
                keyboardType:
                    TextInputType.phone,
                enabled: !otpVerified,
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
                                17),
                      ),
                    ),
                    child: isSendingOtp
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "Send OTP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                  ),
                ),

              otpSection(),

              const SizedBox(height: 22),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Relationship",
                    style: TextStyle(
                      color:
                          AstraTheme.textBlue,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AstraTheme
                          .lightBlue
                          .withOpacity(0.55),
                      borderRadius:
                          BorderRadius.circular(17),
                      border: Border.all(
                        color:
                            AstraTheme.borderBlue,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: relationship,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: "Father",
                            child: Text("Father"),
                          ),
                          DropdownMenuItem(
                            value: "Mother",
                            child: Text("Mother"),
                          ),
                          DropdownMenuItem(
                            value: "Guardian",
                            child: Text("Guardian"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              relationship =
                                  value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: accepted,
                    activeColor:
                        AstraTheme.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        accepted =
                            value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 12),
                      child: Text(
                        "I confirm that the parent / guardian information provided is correct.",
                        style: TextStyle(
                          color:
                              AstraTheme.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (otpVerified) ...[
                const SizedBox(height: 10),
                _verifiedCard(
                  "Parent mobile number verified successfully.",
                ),
              ],

              const SizedBox(height: 25),

              if (!otpVerified)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: null,
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
                                17),
                      ),
                    ),
                    child: const Text(
                      "Verify & Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "SAFE PAYMENTS FOR THE NEXT GENERATION",
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
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _verifiedCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F1),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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
}