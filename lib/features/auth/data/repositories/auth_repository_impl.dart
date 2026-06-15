import 'package:link_note/features/auth/domain/entities/auth_state_event.dart';
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

  @override
  void saveUserId() {
    final userId = _remote.currentUserId;
    if (userId == null) return;

    _cache.setString(key: ExternalConsts.lastUserIdKey, value: userId);
  }

  @override
  void removerUserId() {
    _cache.remove(key: ExternalConsts.lastUserIdKey);
  }

  @override
  Future<void> signUp(UserEntity user) async {
    try {
      final hasConnection = await _networkService.hasConnection();
      if (!hasConnection) throw const InternetException();

      final response = await _remote.signUp(user);

      if (response.user == null) {
        throw const AuthAppException('المستخدم غير مسجل دخول');
      }
    } on AuthException catch (e) {
      final resultMessage = _mapSupabaseSignUpError(e.message);
      throw AuthAppException(resultMessage);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final hasConnection = await _networkService.hasConnection();
      if (!hasConnection) throw const InternetException();

      final response = await _remote.signIn(email: email, password: password);

      final userId = response.user?.id;
      if (userId == null) throw AuthApiException('المستخدم غير مسجل دخول');
    } on AuthException catch (e) {
      final resultMessage = _mapSupabaseSignInError(e.message);
      throw AuthAppException(resultMessage);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final hasConnection = await _networkService.hasConnection();

    if (!hasConnection) throw const InternetException();

    try {
      await _remote.signInWithGoogle();
    } catch (e) {
      throw const AuthAppException(
        'حصلت مشكلة أثناء محاولة التسجيل عبر حساب قوقل',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remote.signOut();
    } catch (e, st) {
      Logger.log(error: e, stackTrace: st);

      if (_remote.currentUserId != null) return;
      throw const AuthAppException('حسلت هناك مشكلة أثناء محاولة تسجيل الخروح');
    }
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
        otpType: OtpType.recovery,
      );
    } on AuthRetryableFetchException catch (_) {
      throw const InternetException();
    } on AppException catch (_) {
      Logger.log(message: 'here');
      rethrow;
    }
  }

  @override
  Stream<AuthStateEvent?> onAuthStateChanged() {
    return _remote.onAuthStateChanged();
  }
}
