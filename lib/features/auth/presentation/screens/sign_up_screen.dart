import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/assets/app_assets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/presentation/widgets/home_button.dart';
import '../../../user/domain/entities/user.dart';
import '../../auth_listeners.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_switcher_text.dart';
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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final ProviderSubscription<AuthState> authSubscription;

  @override
  void initState() {
    authSubscription = ref.listenManual(authControllerProvider, (
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
    super.initState();
  }

  void onSubmit() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    TextInput.finishAutofillContext();

    final user = UserEntity(
      username: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    await ref.read(authControllerProvider.notifier).signUpWithEmail(user);
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
                      key: formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // العنوان
                            const Text(
                              'إنشاء حساب',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00FFFF),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'سجل للحصول على تجربة أفضل في إدارة ملاحظاتك ومزامنتها عبر أجهزتك.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xB4ACBFB6),
                              ),
                            ),

                            const SizedBox(height: 80),

                            GridView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: context.isDesktop ? 2 : 1,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    mainAxisExtent: 130,
                                  ),
                              children: [
                                CustomFullNameField(
                                  nameController: nameController,
                                ),

                                CustomEmailField(emailController),

                                CustomPasswordField(
                                  controller: passwordController,
                                  hintText: 'أدخل كلمة المرور',
                                ),

                                CustomPasswordField(
                                  originalController: passwordController,
                                  controller: confirmPasswordController,
                                  hintText: 'أعد إدخال كلمة المرور',
                                  onSubmit: onSubmit,
                                  textInputAction: TextInputAction.done,
                                  isConfirmField: true,
                                ),
                              ],
                            ),

                            const SizedBox(height: 35),

                            AuthButton(text: 'إنشاء حساب', onPressed: onSubmit),

                            const SizedBox(height: 15),

                            AuthSwitcherText(
                              text: 'لديك حساب بالفعل؟',
                              actionText: 'سجل الدخول',
                              builder: (_) => const SignInScreen(),
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
