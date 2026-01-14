import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/field_label.dart';
import '../../../../core/presentation/widgets/home_button.dart';
import '../../../../core/presentation/widgets/loading_button.dart';
import '../../auth_listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/sign_google_button.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final ProviderSubscription<AuthState> _authSubscription;
  late final StreamSubscription<Uri> _subscribtionsLinks;

  @override
  void initState() {
    super.initState();
    listenAuthStates();
    initDeepLink();
  }

  void listenAuthStates() {
    _authSubscription = ref.listenManual(authProvider, (previous, next) async {
      await authListener(
        context: context,
        previous: previous,
        next: next,
        ref: ref,
      );
    });
  }

  void initDeepLink() {
    final _appLinks = AppLinks();

    _subscribtionsLinks = _appLinks.uriLinkStream.listen((uri) async {
      await ref.read(authProvider.notifier).loginWithUri(uri);
    });
  }

  void onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final password = _passwordController.text;
    final email = _emailController.text;
    await ref
        .read(authProvider.notifier)
        .loginWithEmail(email: email, password: password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription.close();
    _subscribtionsLinks.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [HomeButton()],
        actionsPadding: const EdgeInsets.all(0),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  shrinkWrap: true,
                  children: [
                    // عنوان الشاشة
                    const Text(
                      'أهلا بعودتك!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
            
                    const SizedBox(height: 10),
            
                    const Text(
                      'سجل دخولك إلى حسابك',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(196, 255, 255, 255),
                      ),
                    ),
            
                    const SizedBox(height: 80),
            
                    const FieldLabel(text: 'البريد الإلكتروني'),
            
                    const SizedBox(height: 8),
            
                    CustomEmailField(_emailController),
            
                    const SizedBox(height: 25),
            
                    const FieldLabel(text: 'كلمة المرور'),
            
                    const SizedBox(height: 8),
            
                    CustomPasswordField(
                      controller: _passwordController,
                      hintText: 'أدخل كلمة المرور',
                      onSubmit: onSubmit,
                      textInputAction: TextInputAction.done,
                    ),
            
                    const SizedBox(height: 25),
            
                    // نسيت كلمة المرور
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'هل نسيت كلمة المرور؟',
            
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: Forget Password action
                          },
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 25),
            
                    // زر تسجيل الدخول
                    AbsorbPointer(
                      
                      absorbing: ref.watch(authProvider) is AuthLoadingState,
                      child: MainButton(onPressed: onSubmit, text: 'تسجيل الدخول')),
            
                    const SizedBox(height: 15),
            
                    AbsorbPointer(
                      absorbing: ref.watch(authProvider) is AuthLoadingState,
                      
                      child: const SignGoogleButton()),
            
                    const SizedBox(height: 25),
            
                    // الانتقال إلى التسجيل
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'ليس لديك حساب؟ ',
                        children: [
                          const TextSpan(text: '  '),
            
                          TextSpan(
                            text: 'سجل الآن',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushReplacementTo(const SignUpScreen());
                              },
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
