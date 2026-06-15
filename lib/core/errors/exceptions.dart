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

class CreateSessionException extends AppException {
  const CreateSessionException([super.message= 'فشل إنشاء الجلسة، يرجى المحاولة مرة أخرى.']);
}

class AddMemberToSessionException extends AppException {
  const AddMemberToSessionException([super.message= 'تعذر إضافة العضو إلى الجلسة. يرجى إعادة المحاولة.']);
}

class RemoveMemberFromSessionException extends AppException {
  const RemoveMemberFromSessionException([super.message= 'تعذر حذف العضو من الجلسة. يرجى إعادة المحاولة.']);
}

class RemoveSessionException extends AppException {
  const RemoveSessionException([super.message= 'تعذر إزالة الجلسة. يرجى إعادة المحاولة.']);
}

class GetSessionException extends AppException {
  const GetSessionException([super.message= 'تعذر العثور على الجلسة، قد تكون غير موجودة أو تم إزالتها.',
  ]);
}