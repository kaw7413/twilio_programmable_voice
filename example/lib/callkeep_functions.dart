import 'dart:async';

import 'package:callkeep/callkeep.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

import 'utils/callkeep_config.dart';

FlutterCallkeep _callKeep;

Future<void> initCallKeep(FlutterCallkeep callKeep) async {
  _callKeep = callKeep;
  _callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
  _callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
  _callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
  _callKeep.on(
      CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
  _callKeep.on(CallKeepDidToggleHoldAction(), didToggleHoldCallAction);
  _callKeep.on(
      CallKeepDidPerformSetMutedCallAction(), didPerformSetMutedCallAction);
  _callKeep.on(CallKeepPerformEndCallAction(), endCall);
  _callKeep.on(CallKeepPushKitToken(), onPushKitToken);
  _callKeep.setup(callKeepSetupConfig);
}

void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
  var callUUID = TwilioProgrammableVoice().getCall.sid;
  var number = event.handle;
  print('[displayIncomingCall] $callUUID number: $number');
}

Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
  final String callUUID = TwilioProgrammableVoice().getCall.sid;
  final String from = TwilioProgrammableVoice().getCall.from;
  print('[answerCall] $callUUID, from: $from');

  TwilioProgrammableVoice().answer();

  _callKeep.setCurrentCallActive(callUUID);
}

Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
  print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
}

Future<void> didReceiveStartCallAction(
    CallKeepDidReceiveStartCallAction event) async {
  print('[didReceiveStartCallAction] method called');

  if (event.handle == null) {
    print('[didReceiveStartCallAction] handle == null');
    // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
    return;
  }

  final String callUUID = TwilioProgrammableVoice().getCall.sid;

  print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

  _callKeep.startCall(callUUID, TwilioProgrammableVoice().getCall.from, "Caller Name");

  Timer(const Duration(seconds: 1), () {
    print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
    _callKeep.setCurrentCallActive(callUUID);
  });
}

Future<void> didToggleHoldCallAction(
    CallKeepDidToggleHoldAction event) async {
  print(
      '[didToggleHoldCallAction] ${event.callUUID}, hold (${TwilioProgrammableVoice().getCall.isOnHold})');
}

Future<void> didPerformSetMutedCallAction(
    CallKeepDidPerformSetMutedCallAction event) async {
  print(
      '[didPerformSetMutedCallAction] ${event.callUUID}, muted: ${TwilioProgrammableVoice().getCall.isMuted}');
}

Future<void> endCall(CallKeepPerformEndCallAction event) async {
  print('endCall: ${event.callUUID}');
  await TwilioProgrammableVoice().reject();
}



void onPushKitToken(CallKeepPushKitToken event) {
  print('[onPushKitToken] token => ${event.token}');
}