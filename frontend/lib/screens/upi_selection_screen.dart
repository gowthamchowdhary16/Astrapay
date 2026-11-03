import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'wallet_dashboard_screen.dart';

class UPISelectionScreen extends StatefulWidget {
  const UPISelectionScreen({
    super.key,
  });

  @override
  State<UPISelectionScreen> createState() => _UPISelectionScreenState();
}

class _UPISelectionScreenState extends State<UPISelectionScreen> {
  final TextEditingController customController =
      TextEditingController();

  late List<String> suggestedIds;

  String? selectedUpiId;
  bool checkingAvailability = false;
  bool customAvailable = false;
  bool customChecked = false;

  @override
  void initState() {
    super.initState();
    suggestedIds = _generateSuggestions();

    if (suggestedIds.isNotEmpty) {
      selectedUpiId = suggestedIds.first;
    }
  }

  @override
  void dispose() {
    customController.dispose();
    super.dispose();
  }

  List<String> _generateSuggestions() {
    final random = Random();

    final number1 = 1000 + random.nextInt(9000);
    final number2 = 1000 + random.nextInt(9000);
    final number3 = 1000 + random.nextInt(9000);

    return [
      'gowtham$number1@astrapay',
      'astrauser$number2@astrapay',
      'payuser$number3@astrapay',
      'juniorpay@astrapay',
    ];
  }

  String get mobileBasedId {
    // Demo mobile-number-based UPI ID.
    return '9876543210@astrapay';
  }

  String? get currentCustomId {
    final value = customController.text
        .trim()
        .toLowerCase()
        .replaceAll(' ', '');

    if (value.isEmpty) {
      return null;
    }

    if (value.contains('@')) {
      return value;
    }

    return '$value@astrapay';
  }

  bool _isValidCustomId(String value) {
    final username = value.split('@').first;

    if (username.length < 4) {
      return false;
    }

    final validPattern = RegExp(
      r'^[a-zA-Z0-9._]+@astrapay$',
    );

    return validPattern.hasMatch(value);
  }

  Future<void> checkCustomAvailability() async {
    final id = currentCustomId;

    if (id == null || id.isEmpty) {
      _showMessage('Enter a custom UPI ID first.');
      return;
    }

    if (!_isValidCustomId(id)) {
      _showMessage(
        'Use a valid ID such as gowtham@astrapay.',
      );
      return;
    }

    setState(() {
      checkingAvailability = true;
      customChecked = false;
    });

    // Demo availability check.
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    setState(() {
      checkingAvailability = false;
      customAvailable = true;
      customChecked = true;
      selectedUpiId = id;
    });

    _showMessage(
      '$id is available.',
      success: true,
    );
  }

  void selectId(String id) {
    setState(() {
      selectedUpiId = id;
      customChecked = false;
    });
  }

  void selectCustom() {
    final id = currentCustomId;

    if (id == null) {
      _showMessage('Enter a custom UPI ID first.');
      return;
    }

    if (!customChecked || !customAvailable) {
      _showMessage(
        'Check availability before selecting this ID.',
      );
      return;
    }

    setState(() {
      selectedUpiId = id;
    });
  }

  void continueToWallet() {
    final selected = selectedUpiId;

    if (selected == null || selected.isEmpty) {
      _showMessage('Please select a UPI ID.');
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletDashboardScreen(),
      ),
      (route) => false,
    );
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green : AstraTheme.deepBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildTitle(),
                    const SizedBox(height: 24),
                    _buildSuggestedSection(),
                    const SizedBox(height: 18),
                    _buildMobileNumberOption(),
                    const SizedBox(height: 18),
                    _buildCustomSection(),
                    const SizedBox(height: 20),
                    _buildPermanentInfo(),
                    const SizedBox(height: 28),
                    _buildContinueButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
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
              size: 20,
              color: AstraTheme.textBlue,
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

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your UPI ID',
          style: TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a unique UPI ID for your AstraPay account.',
          style: TextStyle(
            color: AstraTheme.secondaryText,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested UPI IDs',
          style: TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...suggestedIds.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final id = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildUpiOption(
                id: id,
                popular: index == 0,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpiOption({
    required String id,
    bool popular = false,
  }) {
    final selected = selectedUpiId == id;

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        selectId(id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AstraTheme.lightBlue
              : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? AstraTheme.primaryBlue
                : AstraTheme.borderBlue,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AstraTheme.primaryBlue
                    : AstraTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alternate_email_rounded,
                color: selected
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
                    id,
                    style: const TextStyle(
                      color: AstraTheme.textBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'AstraPay UPI ID',
                    style: TextStyle(
                      color: AstraTheme.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (popular)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AstraTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: AstraTheme.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? AstraTheme.primaryBlue
                  : AstraTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNumberOption() {
    final selected = selectedUpiId == mobileBasedId;

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        selectId(mobileBasedId);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AstraTheme.lightBlue
              : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? AstraTheme.primaryBlue
                : AstraTheme.borderBlue,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AstraTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: AstraTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mobile Number UPI ID',
                    style: TextStyle(
                      color: AstraTheme.textBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Use your mobile number',
                    style: TextStyle(
                      color: AstraTheme.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              mobileBasedId,
              style: const TextStyle(
                color: AstraTheme.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? AstraTheme.primaryBlue
                  : AstraTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSection() {
    final id = currentCustomId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AstraTheme.borderBlue,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Custom UPI ID',
            style: TextStyle(
              color: AstraTheme.textBlue,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Create your own unique AstraPay ID.',
            style: TextStyle(
              color: AstraTheme.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: customController,
            onChanged: (_) {
              setState(() {
                customChecked = false;
                customAvailable = false;
              });
            },
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'yourname@astrapay',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.alternate_email_rounded,
                color: AstraTheme.primaryBlue,
              ),
              suffixText: '@astrapay',
              suffixStyle: const TextStyle(
                color: AstraTheme.secondaryText,
                fontWeight: FontWeight.w700,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AstraTheme.borderBlue,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AstraTheme.borderBlue,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AstraTheme.primaryBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: checkingAvailability
                      ? null
                      : checkCustomAvailability,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        AstraTheme.primaryBlue,
                    side: const BorderSide(
                      color: AstraTheme.primaryBlue,
                    ),
                    minimumSize:
                        const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                  ),
                  child: checkingAvailability
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Check Availability',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                ),
              ),
              if (customChecked &&
                  customAvailable) ...[
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAFBF0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                  ),
                ),
              ],
            ],
          ),
          if (id != null &&
              customChecked &&
              customAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: selectCustom,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$id is available',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Text(
                        'Select',
                        style: TextStyle(
                          color: AstraTheme.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermanentInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AstraTheme.lightBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AstraTheme.borderBlue,
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AstraTheme.primaryBlue,
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Choose carefully. Your UPI ID is used to receive payments and may be permanent after activation.',
              style: TextStyle(
                color: AstraTheme.textBlue,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final enabled =
        selectedUpiId != null &&
        selectedUpiId!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled
            ? continueToWallet
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AstraTheme.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AstraTheme.borderBlue,
          disabledForegroundColor:
              AstraTheme.secondaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Wallet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}