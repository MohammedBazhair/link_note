import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/centered_divider_text.dart';
import '../../../../core/presentation/widgets/home_button.dart';
import '../../auth_listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_switcher_text.dart';
import '../widgets/custom_email_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/sign_google_button.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
  }

  void listenAuthStates() {
    _authSubscription = ref.listenManual(authControllerProvider, (
      previous,
      next,
    ) async {
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
       Logger.log(message:  'URI = $uri');
      await ref.read(authControllerProvider.notifier).loginWithUri(uri);
    });
  }

  void onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    TextInput.finishAutofillContext();
    final password = _passwordController.text;
    final email = _emailController.text;

    await ref
        .read(authControllerProvider.notifier)
        .loginWithEmail(email: email, password: password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription.close();
    _subscribtionsLinks.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(authControllerProvider.notifier).reset();
      Logger.log(message: 'resumed');
    }
  }

  bool get isDesktop => context.isDesktop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagesBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  actions: const [HomeButton()],
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
                  automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),

                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // عنوان الشاشة
                            const Text(
                              'أهلا بعودتك!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00FFFF),
                              ),
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

                            GridView(
                              physics: const NeverScrollableScrollPhysics(),

                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isDesktop ? 2 : 1,
                                    mainAxisSpacing: isDesktop ? 24 : 12,
                                    crossAxisSpacing: isDesktop ? 24 : 12,
                                    mainAxisExtent: 130,
                                  ),

                              children: [
                                CustomEmailField(_emailController),

                                CustomPasswordField(
                                  controller: _passwordController,
                                  hintText: 'أدخل كلمة المرور',
                                  onSubmit: onSubmit,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // نسيت كلمة المرور
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'هل نسيت كلمة المرور؟',

                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.pushTo(const ResetPasswordScreen());
                                  },
                                style: const TextStyle(
                                  color: Color(0xFF00FFFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            AuthButton(
                              text: 'تسجيل الدخول',
                              onPressed: onSubmit,
                            ),

                            const SizedBox(height: 15),
                            const CenteredDividerText(text: 'أو'),
                            const SizedBox(height: 15),

                            const SignGoogleButton(),

                            const SizedBox(height: 25),

                            AuthSwitcherText(
                              text: 'ليس لديك حساب؟',
                              actionText: 'سجل الآن',
                              builder: (_) => const SignUpScreen(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
