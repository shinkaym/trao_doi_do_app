import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;
  bool _isOtpLoading = false;
  String _currentOtp = '';
  int _remainingTime = 300; // 5 phút
  bool _canResend = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleSendRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Giả lập gửi yêu cầu
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _isEmailSent = true;
        _remainingTime = 300; // Reset timer
        _canResend = false;
      });

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP đã được gửi đến ${_emailController.text}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Bắt đầu đếm ngược
      _startCountdown();
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        _startCountdown();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _handleVerifyOtp() async {
    if (_currentOtp.length == 6) {
      setState(() => _isOtpLoading = true);

      // Giả lập xác thực OTP
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isOtpLoading = false);

      // Giả lập OTP đúng (trong thực tế sẽ gọi API)
      if (_currentOtp == '123456') {
        // OTP đúng - chuyển đến màn hình đặt lại mật khẩu
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP xác thực thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Chuyển đến màn hình reset password
        context.goNamed('reset-password', extra: _emailController.text);
      } else {
        // OTP sai
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP không chính xác. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
        _otpController.clear();
        setState(() => _currentOtp = '');
      }
    }
  }

  void _handleBackToLogin() {
    context.goNamed('login');
  }

  void _handleResendOtp() {
    if (_canResend) {
      _handleSendRequest();
    }
  }

  void _handleBackToEmail() {
    setState(() {
      _isEmailSent = false;
      _currentOtp = '';
      _otpController.clear();
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_isEmailSent) {
                _handleBackToEmail();
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('login');
              }
            },
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 60 : 40,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: isTablet ? 100 : 80,
                          height: isTablet ? 100 : 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _isEmailSent
                                ? Icons.security_outlined
                                : Icons.lock_reset_outlined,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          _isEmailSent ? 'Nhập mã OTP' : 'Quên mật khẩu',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          _isEmailSent
                              ? 'Nhập mã OTP được gửi đến email của bạn'
                              : 'Nhập email để đặt lại mật khẩu',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 18 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child:
                        _isEmailSent ? _buildOtpContent() : _buildFormContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: isTablet ? 40 : 32),

          // Mô tả
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: isTablet ? 24 : 20,
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: Text(
                    'Nhập địa chỉ email đã đăng ký. Chúng tôi sẽ gửi mã OTP qua email của bạn.',
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: isTablet ? 16 : 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Email input
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              context,
              label: 'Email',
              hint: 'Nhập email của bạn',
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleSendRequest(),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Nút gửi yêu cầu
          SizedBox(
            height: isTablet ? 56 : 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Gửi mã OTP',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'hoặc',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          SizedBox(height: isTablet ? 32 : 24),

          // Link về đăng nhập
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nhớ mật khẩu? ',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              GestureDetector(
                onTap: _handleBackToLogin,
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 40 : 32),
        ],
      ),
    );
  }

  Widget _buildOtpContent() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: isTablet ? 40 : 32),

        // Email info
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: colorScheme.primary,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã OTP đã được gửi đến:',
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // OTP Input
        Text(
          'Nhập mã OTP (6 chữ số)',
          style: TextStyle(
            color: theme.hintColor,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: isTablet ? 60 : 50,
            fieldWidth: isTablet ? 50 : 40,
            activeFillColor: colorScheme.surface,
            selectedFillColor: colorScheme.surface,
            inactiveFillColor: colorScheme.surface,
            activeColor: colorScheme.primary,
            selectedColor: colorScheme.primary,
            inactiveColor: theme.dividerColor,
            borderWidth: 2,
          ),
          enableActiveFill: true,
          cursorColor: colorScheme.primary,
          textStyle: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          onChanged: (value) {
            setState(() {
              _currentOtp = value;
            });
          },
          onCompleted: (value) {
            _handleVerifyOtp();
          },
        ),
        SizedBox(height: isTablet ? 24 : 20),

        // Timer and resend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _canResend
                  ? 'Có thể gửi lại mã'
                  : 'Gửi lại sau: ${_formatTime(_remainingTime)}',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 14 : 12,
              ),
            ),
            GestureDetector(
              onTap: _canResend ? _handleResendOtp : null,
              child: Text(
                'Gửi lại mã',
                style: TextStyle(
                  color: _canResend ? colorScheme.primary : theme.disabledColor,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  decoration: _canResend ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Verify button
        SizedBox(
          height: isTablet ? 56 : 50,
          child: ElevatedButton(
            onPressed:
                (_isOtpLoading || _currentOtp.length != 6)
                    ? null
                    : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isOtpLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      'Xác thực OTP',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        SizedBox(height: isTablet ? 24 : 20),

        // Help text
        Container(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lưu ý:',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                '• Kiểm tra cả thư mục spam/junk\n'
                '• Mã OTP có hiệu lực trong 5 phút\n'
                '• Nhập đúng 6 chữ số để xác thực',
                style: TextStyle(
                  color: theme.hintColor,
                  fontSize: isTablet ? 14 : 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 32 : 24),

        // Back to login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nhớ mật khẩu? ',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            GestureDetector(
              onTap: _handleBackToLogin,
              child: Text(
                'Đăng nhập',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 40 : 32),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        color: theme.hintColor.withOpacity(0.7),
        fontSize: 16,
      ),
      labelStyle: TextStyle(
        color: theme.hintColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(icon, color: theme.hintColor, size: 22),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      suffixIcon:
          suffix != null
              ? Padding(padding: const EdgeInsets.only(left: 12), child: suffix)
              : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.6),
          width: 1,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
      ),
      errorStyle: TextStyle(
        color: theme.colorScheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}
