part of 'call_bloc.dart';

@immutable
abstract class CallEvent {}

class CallEmited extends CallEvent {
  final String contactPerson;

  CallEmited({required this.contactPerson});
}

class CallAnswered extends CallEvent {
  final String uuid;
  final String contactPerson;

  CallAnswered({required this.uuid, required this.contactPerson});
}

class CallCancelled extends CallEvent {
  final String uuid;

  CallCancelled({required this.uuid});
}

class CallEnded extends CallEvent {
  final String uuid;

  CallEnded({required this.uuid});
}

// Call Actions

class CallToggleMute extends CallEvent {
  final bool setOn;

  CallToggleMute({required this.setOn});
}

class CallToggleSpeaker extends CallEvent {
  final bool setOn;

  CallToggleSpeaker({required this.setOn});
}

class CallToggleHold extends CallEvent {
  final bool setOn;

  CallToggleHold({required this.setOn});
}
