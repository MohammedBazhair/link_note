import '../../domain/entities/session.dart';
import '../../domain/entities/session_member.dart';

sealed class SessionState {
 const SessionState({this.session, this.currentMember});

  final Session? session;
  final SessionMember? currentMember;
}

class InitialSessionState extends SessionState {
 const InitialSessionState();
}

class CreateSessionState extends SessionState {
  CreateSessionState({super.session, super.currentMember});
}

class AddMemberState extends SessionState {
  AddMemberState({super.session, super.currentMember});
}

class JoinSessionState extends SessionState {
  JoinSessionState({super.session, super.currentMember});
}

class EndedSessionState extends SessionState {
 const EndedSessionState() : super();
}

class MemberLeavedSessionState extends SessionState {
 const MemberLeavedSessionState() : super();
}

class ErrorSessionState extends SessionState {
  ErrorSessionState({required this.message}) : super();

  final String message;
}
