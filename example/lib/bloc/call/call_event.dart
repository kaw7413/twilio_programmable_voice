part of 'call_bloc.dart';

@immutable
abstract class CallEvent {}

class CallEmited extends CallEvent {
  final String contactPerson;

  CallEmited({this.contactPerson});
}

class CallAnswered extends CallEvent {
  final String uuid;
  final String contactPerson;

  CallAnswered({this.uuid, this.contactPerson});
}

class CallCancelled extends CallEvent {
  final String uuid;

  CallCancelled({this.uuid});
}

class CallEnded extends CallEvent {
  final String uuid;

  CallEnded({this.uuid});
}

// Call Actions

class CallToggleMute extends CallEvent {
  final bool setOn;

  CallToggleMute({this.setOn});
}

class CallToggleSpeaker extends CallEvent {
  final bool setOn;

  CallToggleSpeaker({this.setOn});
}

class CallToggleHold extends CallEvent {
  final bool setOn;

  CallToggleHold({this.setOn});
}
