// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Web/Introduction/widgets/animated_gradient.dart';
import 'package:project/Web/LoginScreen/Buttons/buildsocialbutton.dart';
import 'package:project/Web/LoginScreen/QR_Screen/qr_screen.dart';
import 'package:project/Web/LoginScreen/animated_icon.dart';
import 'package:project/colors/colors_scheme.dart';
import 'package:project/firebase_logic/Login_Auth/login_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPassVisible = true;
  bool _isLoginMode = true;
  bool isQRscanner = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            EquidistantMovingIconsBackground(
              icons: const [Icons.bubble_chart],
              iconColor: Colors.blue.withOpacity(0.3),
              iconSize: 80,
              duration: const Duration(seconds: 10),
              direction: const Offset(1, 0.5),
            ),
            Center(
              child: Container(
                width: 800,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: !isQRscanner
                      ? _buildLoginContent()
                      : QRCodeDisplayScreen(onTap: _toggleQRScanner),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildLoginContent() => Row(
        key: ValueKey<bool>(!isQRscanner),
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                        backgroundColor: AppColors.honoluluBlue,
                        child: Icon(Icons.bubble_chart,
                            color: AppColors.lightFontColor)),
                    const SizedBox(height: 10),
                    _buildAnimatedText(),
                    const SizedBox(height: 10),
                    if (!_isLoginMode)
                      _buildAnimatedTextField('Full Name', Icons.person,
                          _nameController, _validateName),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      validator: _validatePassword,
                    ),
                    if (!_isLoginMode)
                      _buildAnimatedTextField('Confirm Password', Icons.lock,
                          _confirmPasswordController, _validateConfirmPassword,
                          isPassword: true),
                    if (_isLoginMode) _buildForgotPasswordButton(),
                    const SizedBox(height: 10),
                    _buildActionButton(),
                    const SizedBox(height: 10),
                    _buildToggleModeButton(),
                    if (_isLoginMode) _buildSocialLoginButtons(),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              child: AnimatedGradient(
                  color: [AppColors.pacificCyan, AppColors.federalBlue]),
            ),
          )
        ],
      );

  Widget _buildAnimatedTextField(String hintText, IconData prefixIcon,
          TextEditingController controller, String? Function(String?) validator,
          {bool isPassword = false}) =>
      AnimatedOpacity(
        opacity: _isLoginMode ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isLoginMode ? 0 : 80,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller,
                  hintText: hintText,
                  prefixIcon: prefixIcon,
                  isPassword: isPassword,
                  validator: validator,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) =>
      TextFormField(
        controller: controller,
        style: const TextStyle(color: AppColors.darkFontColor),
        obscureText: isPassword ? _isPassVisible : false,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.darkFontColor.withOpacity(0.5)),
          prefixIcon: Icon(prefixIcon, color: AppColors.honoluluBlue),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () =>
                      setState(() => _isPassVisible = !_isPassVisible),
                  icon: Icon(
                      _isPassVisible ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.honoluluBlue),
                )
              : null,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.honoluluBlue)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.honoluluBlue)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.pacificCyan, width: 2)),
        ),
      );

  Widget _buildActionButton() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.honoluluBlue,
          foregroundColor: AppColors.lightFontColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          shadowColor: AppColors.honoluluBlue.withOpacity(0.3),
        ),
        onPressed: _submitForm,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isLoginMode ? 'Login' : 'Sign Up',
            key: ValueKey<bool>(_isLoginMode),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
      );

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      UserCredential? user;
      String text;
      if (_isLoginMode) {
        user = await loginEmailPass(
            context, _emailController.text, _passwordController.text);
        text = "Sucessful Login......";
      } else {
        user = await signupEmailPass(context, _emailController.text,
            _passwordController.text, _nameController.text);
        text = "Sucessful Signup......";
      }
      clearControllers();
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(returnSuccessSnackbar(text));
      }
    }
  }

  Widget _buildAnimatedText() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey<bool>(_isLoginMode),
          children: [
            Text(
              _isLoginMode ? 'Sign in with email' : 'Sign up',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.federalBlue),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoginMode
                  ? 'Login to access your account'
                  : 'Create a new account to get started',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkFontColor),
            ),
          ],
        ),
      );

  Widget _buildForgotPasswordButton() => AnimatedOpacity(
        opacity: _isLoginMode ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isLoginMode ? 40 : 0,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text('Forgot password?',
                    style: TextStyle(color: AppColors.honoluluBlue)),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

  Widget _buildToggleModeButton() => TextButton(
        onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isLoginMode
                ? 'Don\'t have an account? Sign Up'
                : 'Already have an account? Login',
            key: ValueKey<bool>(_isLoginMode),
            style: const TextStyle(color: AppColors.honoluluBlue),
          ),
        ),
      );

  Widget _buildSocialLoginButtons() => AnimatedOpacity(
        opacity: _isLoginMode ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isLoginMode ? 150 : 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 15),
                const Text('Or sign in with',
                    style: TextStyle(color: AppColors.darkFontColor)),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: returnListOfButtons(context, _toggleQRScanner)),
              ],
            ),
          ),
        ),
      );

  void _toggleQRScanner() => setState(() => isQRscanner = !isQRscanner);
}
