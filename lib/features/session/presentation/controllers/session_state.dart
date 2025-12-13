import '../../domain/entities/session.dart';

sealed class SessionState {
  SessionState({this.session, });

  final Session? session;
}

class InitialSessionState extends SessionState {
  InitialSessionState();
}

class CreateSessionState extends SessionState {
  CreateSessionState({ super.session,});
}

class AddMemberState extends SessionState {
  AddMemberState({ super.session,});
}

class JoinSessionState extends SessionState {
  JoinSessionState({ super.session,});
}

class EndedSessionState extends SessionState {
  EndedSessionState() : super(session: null, );
}



class ErrorSessionState extends SessionState {
  ErrorSessionState({ super.session,  required this.message});

  final String message;
}
