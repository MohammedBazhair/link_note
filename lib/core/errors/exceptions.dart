abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}

class UserNotLoggedInException extends AppException {
  const UserNotLoggedInException(super.message);
}

class AuthAppException extends AppException {
  const AuthAppException(super.message);
}

class CreditsZeroException extends AppException {
  const CreditsZeroException(super.message);
}

class SaveNoteFirstException extends AppException {
  const SaveNoteFirstException(super.message);
}

class AuthFailedException extends AppException {
  const AuthFailedException(super.message);
}

class OtpWrongException extends AppException {
  const OtpWrongException(super.message);
}

class InternetException extends AppException {
  const InternetException([
    super.message =
        'حدث خطأ في الاتصال، تأكد من اتصالك بالانترنت وأعد المحاولة لاحقا',
  ]);
}

class AlreadyRunnedException extends AppException {
  const AlreadyRunnedException(super.message);
}

class PermissionsException extends AppException {
  const PermissionsException(super.message);
}