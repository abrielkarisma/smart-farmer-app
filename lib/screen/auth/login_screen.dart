import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_farmer_app/provider/auth_provider.dart';
import 'package:smart_farmer_app/screen/widgets/button.dart';
import 'package:smart_farmer_app/screen/widgets/text_field.dart';
import 'package:smart_farmer_app/screen/widgets/toast_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

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
                      'Masuk',
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
                              controller: _emailController,
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                isObscureText: true),
                            const SizedBox(height: 60),
                            context.watch<AuthProvider>().loadingState.when(
                                  initial: () => CustomButton(
                                      function: _onSubmit, text: 'Login'),
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  loaded: () => CustomButton(
                                      function: _onSubmit, text: 'Login'),
                                  error: (message) => CustomButton(
                                      function: _onSubmit, text: 'Login'),
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
                              text: 'Dont have an account ? ',
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(color: Color(0xFF3B59BA)),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.goNamed('register'),
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

  void _onSubmit() async {
    final provider = context.read<AuthProvider>();
    if (formKey.currentState!.validate()) {
      bool result = false;

      result = await provider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', provider.role!);
        // ToastMessage.show(context, provider.message!);
        context.goNamed('home');
      } else {
        if (mounted) {
          ToastMessage.show(context, provider.message!);
        }
      }
    }
  }
}
