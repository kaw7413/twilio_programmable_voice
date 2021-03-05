import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart'
    as TwilioVoice;

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  StreamSubscription<TwilioVoice.CallEvent> callListener;

  // Should we use a new logger instance or share the same across app ?
  final logger = Logger();

  CallBloc() : super(CallInitial()) {
    // TODO: clean this
    callListener = TwilioVoice.TwilioProgrammableVoice()
        .callStatusStream
        .listen((event) async {
      logger.d("[TwilioProgrammableVoice() Event]");

      if (event is TwilioVoice.CallInvite) {
        logger.d("CALL_INVITE", event);
        TwilioVoice.SoundPoolManager.getInstance().playIncoming();
        // await displayIncomingCallInvite(event.from, "CallerDisplayName");
      } else if (event is TwilioVoice.CancelledCallInvite) {
        logger.d("CANCELLED_CALL_INVITE", event);
        TwilioVoice.SoundPoolManager.getInstance().stopRinging();
        TwilioVoice.SoundPoolManager.getInstance().playDisconnect();
      } else if (event is TwilioVoice.CallConnectFailure) {
        logger.d("CALL_CONNECT_FAILURE", event);
        TwilioVoice.SoundPoolManager.getInstance().stopRinging();
      } else if (event is CallRinging) {
        logger.d("CALL_RINGING", event);
        TwilioVoice.SoundPoolManager.getInstance().stopRinging();
        // TwilioProgrammableVoice().getCall.to and TwilioProgrammableVoice().getCall.from are always null when making a call
        // TODO replace brut phone number with TwilioProgrammableVoice().getCall.to
        // await displayMakeCallScreen("+33787934070", "Display Caller Name");
      } else if (event is TwilioVoice.CallConnected) {
        logger.d("CALL_CONNECTED", event);
        TwilioVoice.SoundPoolManager.getInstance().stopRinging();
        this.add(CallAnswered(
            contactPerson: (this.state as CallRinging).contactPerson,
            uuid: event.sid));
      } else if (event is TwilioVoice.CallReconnecting) {
        logger.d("CALL_RECONNECTING", event);
      } else if (event is TwilioVoice.CallReconnected) {
        logger.d("CALL_RECONNECTED", event);
      } else if (event is TwilioVoice.CallDisconnected) {
        logger.d("CALL_DISCONNECTED", event);

        // Maybe we need to ensure their is no ringing with SoundPoolManager.getInstance().stopRinging();
        TwilioVoice.SoundPoolManager.getInstance().playDisconnect();

        this.add(CallEnded(uuid: event.sid));

        // TODO: only end the current active call
        // _callKeep.endAllCalls();
      } else if (event is TwilioVoice.CallQualityWarningChanged) {
        logger.d("CALL_QUALITY_WARNING_CHANGED", event);
      }
    });
  }

  @override
  // This ensure we don't leak the call subscription.
  Future<void> close() async {
    await callListener.cancel();
    return super.close();
  }

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

    if (event is CallCancelled) {
      yield mapCallCancelledToState(event);
    }

    if (event is CallToggleHold) {
      yield mapCallToggleHoldToState(event);
    }

    if (event is CallToggleMute) {
      yield mapCallToggleMuteToState(event);
    }

    if (event is CallToggleSpeaker) {
      yield mapCallToggleSpeakerToState(event);
    }
  }

  CallState mapCallToggleHoldToState(CallToggleHold event) {
    final _state = state;

    if (_state is CallInProgress) {
      TwilioVoice.TwilioProgrammableVoice().hold(setOn: event.setOn);
      return _state.copyWith(isHold: event.setOn);
    }
  }

  CallState mapCallToggleMuteToState(CallToggleMute event) {
    final _state = state;

    if (_state is CallInProgress) {
      TwilioVoice.TwilioProgrammableVoice().mute(setOn: event.setOn);
      return _state.copyWith(isMuted: event.setOn);
    }
  }

  CallState mapCallToggleSpeakerToState(CallToggleSpeaker event) {
    final _state = state;

    if (_state is CallInProgress) {
      TwilioVoice.TwilioProgrammableVoice().toggleSpeaker(setOn: event.setOn);
      return _state.copyWith(isAutioRoutedToSpeaker: event.setOn);
    }
  }

  CallState mapCallCancelledToState(CallCancelled event) {
    // TODO: ask TwilioProgrammableVoice to stop call here.
    return CallInitial();
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
      startedAt: new DateTime.now().toIso8601String(),
      isAudioRoutedToSpeaker: false,
      isHold: false,
      isMuted: false,
    );
  }

  CallState mapCallEndedToState(CallEnded event) {
    return CallInitial();
  }
}
