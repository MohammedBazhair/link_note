import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/core/presentation/screens/home_screen.dart';
import 'package:link_note/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_email_field.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_password_field.dart';
import 'package:link_note/features/auth/services/auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: ListView(
                padding: EdgeInsets.all(24),
                shrinkWrap: true,

                children: [
                  // عنوان الشاشة
                  Text(
                    "Welcome Back ",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Login to your account",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xB4ACBFB6),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  CustomEmailField(emailController),

                  const SizedBox(height: 25),

                  Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  CustomPasswordField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                  ),

                  const SizedBox(height: 12),

                  // نسيت كلمة المرور
                  TextButton(
                    onPressed: () {
                      // TODO: Forget Password action
                    },
                    child: const Text("Forgot Password?"),
                  ),

                  const SizedBox(height: 25),

                  // زر تسجيل الدخول
                  StatefulBuilder(
                    builder: (context, rebuild) {
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final isValid =
                                    formKey.currentState?.validate() ?? false;

                                if (!isValid) return;
                                rebuild(() => isLoading = true);

                                final password = passwordController.text;
                                final email = emailController.text;
                                final error = await AuthService().signIn(
                                  email: email,
                                  password: password,
                                );

                                rebuild(() => isLoading = false);
                                if (error != null) {
                                  context.showSnakbar(error);
                                  return;
                                }

                                TextInput.finishAutofillContext();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              },
                        child: isLoading
                            ? CircularProgressIndicator()
                            : const Text("Login"),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // الانتقال إلى التسجيل
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text("Don’t have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
