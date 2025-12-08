import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/home_button.dart';
import '../../../user/domain/entities/user.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../../listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_fullname_field.dart';
import '../widgets/custom_password_field.dart';
import 'sign_in_screen.dart';

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
  late final ProviderSubscription<AuthState> authSubscription;

  @override
  void initState() {
    authSubscription = ref.listenManual(authProvider, (previous, next) {
      authListener(context: context, previous: previous, next: next);
    });
    super.initState();
  }

  void onSubmit() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    ref.read(loadingProvider.notifier).state = true;
final userCtrl = ref.read(userControllerProvider.notifier);

    final user = UserEntity(
      username: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );


    await ref.read(authProvider.notifier).signUp(user);
    await userCtrl.createProfile(user);

    ref.read(loadingProvider.notifier).state = false;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [HomeButton()]),

      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,

                children: [
                  // العنوان
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(fontSize: 14, color: Color(0xB4ACBFB6)),
                  ),

                  const SizedBox(height: 80),

                  // الاسم
                  const Text(
                    'Full Name',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  CustomFullNameField(nameController: nameController),

                  const SizedBox(height: 25),

                  // البريد
                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  CustomEmailField(emailController),
                  const SizedBox(height: 25),

                  // كلمة المرور
                  const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  CustomPasswordField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                  ),

                  const SizedBox(height: 25),

                  // تأكيد كلمة المرور
                  const Text(
                    'Confirm Password',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),

                  CustomPasswordField(
                    originalController: passwordController,
                    controller: confirmPasswordController,
                    hintText: 'Enter your confirm password',
                    onSubmit: onSubmit,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 35),

                  // زر إنشاء الحساب
                  Consumer(
                    builder: (_, ref, __) {
                      final isLoading = ref.watch(loadingProvider);
                      return ElevatedButton(
                        onPressed: isLoading ? null : onSubmit,
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Sign Up'),
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
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    child: const Text('Already have an account? Sign in'),
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
