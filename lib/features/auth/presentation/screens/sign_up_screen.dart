import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_note/core/extensions/extensions.dart';
import 'package:link_note/core/presentation/screens/home_screen.dart';
import 'package:link_note/core/presentation/widgets/home_button.dart';
import 'package:link_note/features/auth/presentation/controllers/auth_controller.dart';
import 'package:link_note/features/auth/presentation/controllers/auth_state.dart';
import 'package:link_note/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_email_field.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_fullname_field.dart';
import 'package:link_note/features/auth/presentation/widgets/custom_password_field.dart';
import 'package:link_note/features/user/domain/entities/user.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    ref.listen(authProvider, (previous, next) {
      switch (next) {
        case AuthInitialState():
          break;

        case AuthSuccessfullState():
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );

        case AuthFailedState(:final message):
          context.showSnakbar(message);
      }
    });
    super.initState();
  }

  void onSubmit(void Function(void Function()) rebuild) async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    rebuild(() => isLoading = true);

    final user = UserEntity(
      username: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    await ref.read(authProvider.notifier).signUp(user);

    rebuild(() => isLoading = false);
  }

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
      appBar: AppBar(actions: [HomeButton()]),

      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: ListView(
                padding: EdgeInsets.all(24),
                shrinkWrap: true,

                children: [
                  // العنوان
                  Text(
                    "Create Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign up to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xB4ACBFB6),
                    ),
                  ),

                  const SizedBox(height: 80),

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
                        onPressed: isLoading ? null : () => onSubmit(rebuild),
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
                      Navigator.pushReplacement(
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
