import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'upi_selection_screen.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({
    super.key,
  });

  @override
  State<FaceVerificationScreen> createState() =>
      _FaceVerificationScreenState();
}

class _FaceVerificationScreenState
    extends State<FaceVerificationScreen> {
  Timer? verificationTimer;

  bool verificationStarted = false;
  bool goodLighting = false;
  bool faceDetected = false;
  bool livenessChecked = false;
  bool verificationCompleted = false;

  int currentStep = 0;

  @override
  void dispose() {
    verificationTimer?.cancel();
    super.dispose();
  }

  void startFaceVerification() {
    if (verificationStarted) return;

    setState(() {
      verificationStarted = true;
      currentStep = 0;
      goodLighting = false;
      faceDetected = false;
      livenessChecked = false;
      verificationCompleted = false;
    });

    verificationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          currentStep++;
        });

        if (currentStep == 1) {
          setState(() {
            goodLighting = true;
          });
        }

        if (currentStep == 2) {
          setState(() {
            faceDetected = true;
          });
        }

        if (currentStep == 3) {
          setState(() {
            livenessChecked = true;
          });
        }

        if (currentStep >= 4) {
          timer.cancel();

          setState(() {
            verificationCompleted = true;
          });
        }
      },
    );
  }

  void continueToNextStep() {
    if (!verificationCompleted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UPISelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06132F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  30,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    _buildHeading(),
                    const SizedBox(height: 30),
                    _buildFaceScanner(),
                    const SizedBox(height: 32),
                    _buildVerificationSteps(),
                    const SizedBox(height: 28),
                    _buildStatus(),
                    const SizedBox(height: 28),
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        20,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Expanded(
            child: Center(
              child: AstraBrand(
                logoSize: 38,
                textSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return const Column(
      children: [
        Text(
          'Verify Your Identity',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Position your face inside the circle',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF9EADD0),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFaceScanner() {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: verificationCompleted
                    ? Colors.greenAccent
                    : AstraTheme.primaryBlue,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: verificationCompleted
                      ? Colors.greenAccent
                          .withValues(alpha: 0.35)
                      : AstraTheme.primaryBlue
                          .withValues(alpha: 0.30),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            width: 235,
            height: 235,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF102550),
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 145,
                  color: Colors.white
                      .withValues(alpha: 0.12),
                ),
                if (verificationStarted &&
                    !verificationCompleted)
                  Positioned(
                    top: 35,
                    left: 25,
                    right: 25,
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      height: 3,
                      decoration: BoxDecoration(
                        color: AstraTheme.primaryBlue,
                        borderRadius:
                            BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: AstraTheme.primaryBlue
                                .withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _corner(
            Alignment.topLeft,
            Border(
              top: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
              left: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
            ),
          ),
          _corner(
            Alignment.topRight,
            Border(
              top: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
              right: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
            ),
          ),
          _corner(
            Alignment.bottomLeft,
            Border(
              bottom: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
              left: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
            ),
          ),
          _corner(
            Alignment.bottomRight,
            Border(
              bottom: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
              right: BorderSide(
                color: AstraTheme.primaryBlue,
                width: 4,
              ),
            ),
          ),
          if (verificationCompleted)
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
        ],
      ),
    );
  }

  Widget _corner(
    Alignment alignment,
    Border border,
  ) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: border,
        ),
      ),
    );
  }

  Widget _buildVerificationSteps() {
    return Column(
      children: [
        _verificationRow(
          title: 'Good Lighting',
          subtitle: 'Lighting conditions detected',
          completed: goodLighting,
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 12),
        _verificationRow(
          title: 'Face Detected',
          subtitle: 'Your face is clearly visible',
          completed: faceDetected,
          icon: Icons.face_retouching_natural_rounded,
        ),
        const SizedBox(height: 12),
        _verificationRow(
          title: 'Liveness Check',
          subtitle: 'Checking that you are present',
          completed: livenessChecked,
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  Widget _verificationRow({
    required String title,
    required String subtitle,
    required bool completed,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFF0D352A)
            : const Color(0xFF0D1E42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed
              ? Colors.greenAccent
                  .withValues(alpha: 0.40)
              : Colors.white
                  .withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green
                  : AstraTheme.primaryBlue
                      .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : icon,
              color: completed
                  ? Colors.white
                  : AstraTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8999BA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!completed &&
              verificationStarted)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AstraTheme.primaryBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    String title;
    String subtitle;

    if (verificationCompleted) {
      title = 'Verification Successful';
      subtitle =
          'Your identity has been verified successfully.';
    } else if (!verificationStarted) {
      title = 'Ready to Verify';
      subtitle =
          'Tap the button below to start face verification.';
    } else {
      title = 'Verifying...';
      subtitle =
          'Please keep your face inside the circle.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verificationCompleted
            ? const Color(0xFF0D352A)
            : const Color(0xFF0D1E42),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: verificationCompleted
              ? Colors.greenAccent
                  .withValues(alpha: 0.35)
              : Colors.white
                  .withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            verificationCompleted
                ? Icons.verified_rounded
                : Icons.security_rounded,
            color: verificationCompleted
                ? Colors.greenAccent
                : AstraTheme.primaryBlue,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8999BA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final String buttonText;

    if (verificationCompleted) {
      buttonText = 'Continue';
    } else if (verificationStarted) {
      buttonText = 'Verifying...';
    } else {
      buttonText = 'Start Face Verification';
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: verificationCompleted
            ? continueToNextStep
            : verificationStarted
                ? null
                : startFaceVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: verificationCompleted
              ? Colors.green
              : AstraTheme.primaryBlue,
          disabledBackgroundColor:
              AstraTheme.primaryBlue
                  .withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (verificationCompleted) ...[
              const SizedBox(width: 9),
              const Icon(
                Icons.arrow_forward_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}