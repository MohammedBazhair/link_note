import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/presentation/widgets/home_button.dart';
import '../../listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_password_field.dart';
import 'sign_up_screen.dart';

final loadingProvider = StateProvider.autoDispose((ref) => false);

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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

    final password = passwordController.text;
    final email = emailController.text;
    await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    ref.read(loadingProvider.notifier).state = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                  // عنوان الشاشة
                  const Text(
                    'Welcome Back ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 14, color: Color(0xB4ACBFB6)),
                  ),

                  const SizedBox(height: 80),

                  const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  CustomEmailField(emailController),

                  const SizedBox(height: 25),

                  const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),

                  const SizedBox(height: 8),

                  CustomPasswordField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                    onSubmit: onSubmit,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 12),

                  // نسيت كلمة المرور
                  TextButton(
                    onPressed: () {
                      // TODO: Forget Password action
                    },
                    child: const Text('Forgot Password?'),
                  ),

                  const SizedBox(height: 25),

                  // زر تسجيل الدخول
                  Consumer(
                    builder: (_, ref, button) {
                      final isLoading = ref.watch(loadingProvider);
                      return isLoading
                          ? const SizedBox.shrink(
                              child: CircularProgressIndicator(),
                            )
                          : button!;
                    },
                    child: ElevatedButton(
                      onPressed: onSubmit,
                      child: const Text('Login'),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // الانتقال إلى التسجيل
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('Don’t have an account? Sign up'),
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
