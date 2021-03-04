import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitial());

  @override
  Stream<CallState> mapEventToState(
    CallEvent event,
  ) async* {
    if (event is CallEmited) {
      yield mapCallEmittedToState(event);
    }

    if (event is CallAnswered) {
      yield mapCallAnsweredToState(event);
    }

    if (event is CallEnded) {
      yield mapCallEndedToState(event);
    }
  }

  CallState mapCallEmittedToState(CallEmited event) {
    return CallRinging(
        contactPerson: event.contactPerson,
        direction: "OUT",
        startedAt: new DateTime.now().toIso8601String(),
        uuid: "My Super UUID");
  }

  CallState mapCallAnsweredToState(CallAnswered event) {
    return CallInProgress(
        contactPerson: event.contactPerson,
        uuid: event.uuid,
        direction: "OUT",
        startedAt: new DateTime.now().toIso8601String());
  }

  CallState mapCallEndedToState(CallEnded event) {
    return CallInitial();
  }
}
