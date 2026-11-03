import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'student_registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double>
      _scaleAnimation;

  late Animation<double>
      _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 1200,
      ),
    );

    _scaleAnimation =
        CurvedAnimation(
      parent: _controller,
      curve:
          Curves.easeOutBack,
    );

    _fadeAnimation =
        CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getStarted() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const StudentRegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      body: Stack(
        children: [
          // ==========================================
          // TOP BLUE GLOW
          // ==========================================

          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    AstraTheme
                        .primaryBlue
                        .withOpacity(
                  0.08,
                ),
              ),
            ),
          ),

          // ==========================================
          // BOTTOM BLUE GLOW
          // ==========================================

          Positioned(
            bottom: -160,
            left: -120,
            child: Container(
              width: 330,
              height: 330,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    AstraTheme
                        .primaryBlue
                        .withOpacity(
                  0.06,
                ),
              ),
            ),
          ),

          // ==========================================
          // MAIN
          // ==========================================

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                FadeTransition(
                  opacity:
                      _fadeAnimation,

                  child:
                      ScaleTransition(
                    scale:
                        _scaleAnimation,

                    child: Column(
                      children: [
                        const AstraBrand(
                          logoSize: 100,
                          textSize: 42,
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        const Text(
                          'Safe Payments for the Next Generation',
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                AstraTheme
                                    .secondaryText,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w500,
                            letterSpacing:
                                0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ======================================
                // GET STARTED
                // ======================================

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),

                  child:
                      SizedBox(
                    width:
                        double.infinity,
                    height: 55,

                    child:
                        ElevatedButton(
                      onPressed:
                          getStarted,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AstraTheme
                                .primaryBlue,
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

                      child:
                          const Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            'Get Started',
                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          SizedBox(
                            width: 9,
                          ),

                          Icon(
                            Icons
                                .arrow_forward_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'YOUR DIGITAL WALLET',
                  style:
                      TextStyle(
                    color:
                        AstraTheme
                            .secondaryText,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing:
                        1.5,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}