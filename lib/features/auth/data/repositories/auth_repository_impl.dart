import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/external_constants/external_constants.dart';
import '../../../../core/constants/internal_constants/log.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/features/database/local/cache_service_interface.dart';
import '../../../../core/features/network/connectivity_service.dart';
import '../../../user/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._networkService, this._cache);
  final AuthRemoteDataSource _remote;
  final ConnectivityService _networkService;
  final SecureCacheService _cache;

  void _saveUserId(String userId) async {
    await _cache.setString(key: ExternalConsts.lastUserIdKey, value: userId);
  }

  @override
  Future<String?> signUp(UserEntity user) async {
    try {
      final response = await _remote.signUp(user);
      if (response.user == null) throw const AuthException('no id found');

      final userId = response.user!.id;
      _saveUserId(userId);
      return null; // تم التسجيل بنجاح
    } on AuthException catch (e) {
      return _mapSupabaseSignUpError(e.message);
    } catch (e) {
      return 'من فضلك تحقق من اتصالك بالإنترنت';
    }
  }

  @override
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.signIn(email: email, password: password);
      final userId = response.user?.id;

      if (userId != null) _saveUserId(userId);

      return null;
    } on AuthApiException catch (e) {
      return _mapSupabaseSignInError(e.message);
    } catch (e) {
      return 'من فضلك تحقق من اتصالك بالإنترنت';
    }
  }

  @override
  Future<void> signInWithGoogle() {
    return _remote.signInWithGoogle();
  }

  @override
  Future<AuthResponse> signInWithUrl(Uri uri) async {
    final code = uri.queryParameters['code'];
    if (code == null) throw ArgumentError.notNull();

    final authResponse = await _remote.exchangeCodeForAuthSession(code);

    final userId = authResponse.user?.id;

    if (userId == null) throw ArgumentError.notNull();

    await _cache.setString(key: ExternalConsts.lastUserIdKey, value: userId);
    return authResponse;
  }

  @override
  Future<void> signOut() async {
    await _cache.remove(key: ExternalConsts.lastUserIdKey);
    return _remote.signOut();
  }

  String _mapSupabaseSignInError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البيانات المدخلة غير صحيحة';
    }

    if (message.contains('Email not confirmed')) {
      return 'من فضلك قم بتأكيد بريدك الإلكتروني قبل تسجيل الدخول';
    }

    if (message.contains('User not found')) {
      return 'هذا المستخدم غير موجود';
    }

    return 'تسجيل الدخول فشل، يرجى المحاولة مرة أخرى';
  }

  String _mapSupabaseSignUpError(String message) {
    if (message.contains('User already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }

    if (message.contains('password')) {
      return 'كلمة المرور ضعيفة جدًا';
    }

    if (message.contains('email')) {
      return 'من فضلك أدخل بريدًا إلكترونيًا صالحًا';
    }

    return 'التسجيل فشل، يرجى المحاولة مرة أخرى';
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _remote.resetPassword(email);
    } on AuthRetryableFetchException catch (_) {
      throw const InternetException();
    } catch (e) {
      throw const AuthException(
        'فشلت عملية ارسال رسالة الى الايميل واستعادة الباسورد',
      );
    }
  }

  @override
  Future<void> updateUser({
    required String email,
    required String newPassword,
    required String nonce,
  }) async {
    try {
      await _remote.updateUser(
        email: email,
        newPassword: newPassword,
        nonce: nonce,
        otpType: OtpType.recovery
      );
    } on AuthRetryableFetchException catch (_) {
      throw const InternetException();
    } on AppException catch (_) {
      Logger.log(message: 'here');
      rethrow;
    }
  }
}
