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

class CreditsZeroException extends AppException {
  const CreditsZeroException(super.message);
}

class SaveNoteFirstException extends AppException {
  const SaveNoteFirstException(super.message);
}

class InternetException extends AppException {
  const InternetException([
    super.message =
        'حدث خطأ في الاتصال، تأكد من اتصالك بالانترنت وأعد المحاولة لاحقا',
  ]);
}
