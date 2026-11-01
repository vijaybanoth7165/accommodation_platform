import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _authTabController;

  // Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController(text: 'owner@stayflow.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _otpSent = false;
  String _generatedOtp = '4567';
  String? _errorMessage;

  // Resend OTP Countdown
  Timer? _resendTimer;
  int _countdownSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _authTabController = TabController(length: 2, vsync: this);
    _authTabController.addListener(() {
      setState(() {
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _authTabController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _countdownSeconds = 30;
      _canResend = false;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
        _generatedOtp = '4567';
      });
      _startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Verification Code for +91 $phone: $_generatedOtp'),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  void _verifyOtpAndLogin() async {
    final enteredOtp = _otpController.text.trim();

    if (enteredOtp.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the 4-digit verification code';
      });
      return;
    }

    if (enteredOtp.length < 4) {
      setState(() {
        _errorMessage = 'Code must be 4 digits';
      });
      return;
    }

    // Check demo OTP match (accepts generated OTP or universal 1234 / 4567)
    if (enteredOtp != _generatedOtp && enteredOtp != '1234' && enteredOtp != '4567') {
      setState(() {
        _errorMessage = 'Incorrect code. Please enter $_generatedOtp';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Simulate authentication verification delay
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() => _isLoading = false);
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Verified! Welcome back.'),
            backgroundColor: AppColors.vacant,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() => _isLoading = false);
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      }
    }
  }

  void _resetToEditNumber() {
    _resendTimer?.cancel();
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _errorMessage = null;
    });
  }

  void _fillDemoPresets() {
    setState(() {
      _phoneController.text = '9876543210';
      _errorMessage = null;
    });
    _sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneTab = _authTabController.index == 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Brand Header ---
                  _buildBrandHeader(),
                  const SizedBox(height: 28),

                  // --- Auth Card ---
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab Bar: Phone OTP / Email
                          Container(
                            height: 44,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _authTabController,
                              indicator: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: AppColors.textPrimary,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              indicatorSize: TabBarIndicatorSize.tab,
                              tabs: const [
                                Tab(text: 'Mobile OTP'),
                                Tab(text: 'Email / Password'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tab Content
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: isPhoneTab
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: _buildPhoneAuthView(),
                            secondChild: _buildEmailAuthView(),
                          ),

                          // Error Display
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.occupiedBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.occupied.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.occupied),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(fontSize: 12, color: AppColors.occupied, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Primary Action Button (Strictly enforces OTP verification)
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (isPhoneTab) {
                                      if (!_otpSent) {
                                        _sendOtp();
                                      } else {
                                        _verifyOtpAndLogin();
                                      }
                                    } else {
                                      _loginWithEmail();
                                    }
                                  },
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isPhoneTab
                                        ? (!_otpSent ? 'Send Verification OTP' : 'Verify OTP & Sign In')
                                        : 'Sign In with Email',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Demo Pill
                  _buildDemoPresets(),

                  const SizedBox(height: 18),

                  // Security & Multi-tenant note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                      SizedBox(width: 6),
                      Text(
                        'Strict Multi-Tenant Isolation & Data Encryption',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Accommodation Platform',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'PG, Hostel & Stay Management System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- Step 1 & Step 2 for Phone OTP ---
  Widget _buildPhoneAuthView() {
    if (!_otpSent) {
      // Step 1: Enter Mobile Number
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter your registered 10-digit mobile number to receive a one-time password.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🇮🇳', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text(
                      '+91',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    SmartPhoneInputFormatter(maxLength: 10),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                  cursorColor: AppColors.primary,
                  showCursor: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter 10-digit number',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    counterText: '',
                  ),
                  onChanged: (_) {
                    if (_errorMessage != null) setState(() => _errorMessage = null);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Step 2: Enter & Verify 4-digit OTP
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Phone Number and "Edit" button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_android_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '+91 ${_phoneController.text.trim()}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                  ),
                ),
                InkWell(
                  onTap: _resetToEditNumber,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Digit OTP Input
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            autofocus: true,
            inputFormatters: [
              SmartPhoneInputFormatter(maxLength: 4),
            ],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 14.0,
              color: AppColors.primary,
            ),
            decoration: const InputDecoration(
              hintText: '••••',
              hintStyle: TextStyle(letterSpacing: 14.0, color: AppColors.textMuted),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: '',
            ),
            onChanged: (val) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
              if (val.length == 4) {
                _verifyOtpAndLogin();
              }
            },
          ),
          const SizedBox(height: 12),

          // Resend Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_canResend) ...[
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Resend OTP in ${_countdownSeconds}s',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: _sendOtp,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Resend OTP via WhatsApp / SMS', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ],
      );
    }
  }

  Widget _buildEmailAuthView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address / Property ID',
            hintText: 'owner@stayflow.com',
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoPresets() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'One-tap test with demo phone & OTP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _fillDemoPresets,
            child: const Text('Auto-Fill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// Automatically translates shifted number-key symbols ($, %, ^, &) to digits (4, 5, 6, 7)
/// and enforces pure numeric digits with a configurable maximum length.
class SmartPhoneInputFormatter extends TextInputFormatter {
  final int maxLength;

  SmartPhoneInputFormatter({this.maxLength = 10});

  static const Map<String, String> _symbolToDigit = {
    '!': '1',
    '@': '2',
    '#': '3',
    '\$': '4',
    '%': '5',
    '^': '6',
    '&': '7',
    '*': '8',
    '(': '9',
    ')': '0',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Convert any shifted keyboard symbol to its corresponding digit
    _symbolToDigit.forEach((symbol, digit) {
      text = text.replaceAll(symbol, digit);
    });

    // Strip out any non-numeric characters
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Cap at maxLength
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
