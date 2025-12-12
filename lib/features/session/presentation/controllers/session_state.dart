import '../../domain/entities/session.dart';
import '../../domain/entities/session_member.dart';

sealed class SessionState {
  SessionState({this.session, this.members = const {}});

  final Session? session;
  final Set<SessionMember> members;
}

class InitialSessionState extends SessionState {
  InitialSessionState();
}

class CreateSessionState extends SessionState {
  CreateSessionState({ super.session, super.members});
}

class AddMemberState extends SessionState {
  AddMemberState({ super.session, super.members});
}

class JoinSessionState extends SessionState {
  JoinSessionState({ super.session, super.members});
}

class EndedSessionState extends SessionState {
  EndedSessionState() : super(session: null, members: {});
}



class ErrorSessionState extends SessionState {
  ErrorSessionState({ super.session, super.members, required this.message});

  final String message;
}
