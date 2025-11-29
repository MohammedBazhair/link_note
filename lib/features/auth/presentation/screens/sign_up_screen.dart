import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/core/presentation/screens/home_screen.dart';
import 'package:link_note/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_email_field.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_fullname_field.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_password_field.dart';
import 'package:link_note/features/auth/services/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // العنوان
                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xB4ACBFB6),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // الاسم
                  Text(
                    "Full Name",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  CustomFullNameField(nameController: nameController),

                  const SizedBox(height: 25),

                  // البريد
                  Text(
                    "Email",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  CustomEmailField(emailController),
                  const SizedBox(height: 25),

                  // كلمة المرور
                  Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  CustomPasswordField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                  ),

                  const SizedBox(height: 25),

                  // تأكيد كلمة المرور
                  Text(
                    "Confirm Password",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  CustomPasswordField(
                    originalController: passwordController,
                    controller: confirmPasswordController,
                    hintText: 'Enter your confirm password',
                  ),

                  const SizedBox(height: 35),

                  // زر إنشاء الحساب
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
                                final error = await AuthService().signUp(
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
                            : const Text("Sign Up"),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // العودة لتسجيل الدخول
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => SignInScreen(),
                        ),
                      );
                    },
                    child: const Text("Already have an account? Sign in"),
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
