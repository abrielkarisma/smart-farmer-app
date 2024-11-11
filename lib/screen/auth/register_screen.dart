import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_farmer_app/provider/auth_provider.dart';
import 'package:smart_farmer_app/screen/widgets/button.dart';
import 'package:smart_farmer_app/screen/widgets/text_field.dart';
import 'package:smart_farmer_app/screen/widgets/toast_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _kodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // String? actor;

  // Future<void> _checkActor() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     actor = prefs.getString('user_role');
  //     print("anjay $actor");
  //   });
  // }
  final actor = const String.fromEnvironment('actor', defaultValue: 'pemilik');

  bool get isOwner => actor == 'pemilik';
  bool get isEmployee => actor == 'petugas';

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _kodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      backgroundColor: const Color(0xFF4E6B3E),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4E6B3E),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                                controller: _nameController, labelText: 'Name'),
                            const SizedBox(height: 12),
                            CustomTextField(
                                controller: _phoneController,
                                labelText: 'Phone Number',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ]),
                            const SizedBox(height: 12),
                            CustomTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress),
                            if (isEmployee)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    controller: _kodeController,
                                    labelText: 'Kode Pemilik',
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              isObscureText: true,
                              counter: true,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm Password',
                              isObscureText: true,
                              counter: true,
                            ),
                            const SizedBox(height: 60),
                            context.watch<AuthProvider>().loadingState.when(
                                  initial: () => CustomButton(
                                      function: _onRegister, text: 'Register'),
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  loaded: () => CustomButton(
                                      function: _onRegister, text: 'Register'),
                                  error: (message) => CustomButton(
                                      function: _onRegister, text: 'Register'),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Already have an account ? ',
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: const TextStyle(color: Color(0xFF3B59BA)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.goNamed('login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onRegister() async {
    final provider = context.read<AuthProvider>();

    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text;
    final phone = _phoneController.text;

    if (formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        ToastMessage.show(context, 'Password not match');
        return;
      }

      if (phone.length < 10 || phone.length > 14) {
        ToastMessage.show(context, 'Phone number not valid');
        return;
      }

      if (isEmployee) {
        await provider
            .registerPetugas(
          email: email,
          password: password,
          name: name,
          phone: phone,
          kodePemilik: _kodeController.text,
        )
            .then((_) {
          if (provider.registerResponse!.success && mounted) {
            context.goNamed('login');
            ToastMessage.show(context, provider.registerResponse!.message);
          } else if (mounted) {
            ToastMessage.show(context, provider.registerResponse!.message);
          }
        }).catchError((error) {
          if (mounted) {
            ToastMessage.show(context, error.toString());
          }
        });
      } else {
        await provider
            .register(
          email: email,
          password: password,
          name: name,
          phone: phone,
        )
            .then((_) {
          if (provider.registerResponse!.success && mounted) {
            context.goNamed('login');
            ToastMessage.show(context, provider.registerResponse!.message);
          } else if (mounted) {
            ToastMessage.show(context, provider.registerResponse!.message);
          }
        }).catchError((error) {
          if (mounted) {
            ToastMessage.show(context, error.toString());
          }
        });
      }
    }
  }
}
