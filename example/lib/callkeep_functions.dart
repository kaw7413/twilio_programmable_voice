import 'package:callkeep/callkeep.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
  var callUUID = TwilioProgrammableVoice.getCall.sid;
  var number = event.handle;
  print('[displayIncomingCall] $callUUID number: $number');
}

// Future<void> answerCall(CallKeepPerformAnswerCallAction event, FlutterCallkeep callKeep) async {
//   final String callUUID = TwilioProgrammableVoice.getCall.sid;
//   final String number = TwilioProgrammableVoice.getCall.to;
//   print('[answerCall] $callUUID, number: $number');
//
//   TwilioProgrammableVoice.answer();
//
//   callKeep.setCurrentCallActive(callUUID);
// }

Future<void> endCall(CallKeepPerformEndCallAction event) async {
  print('endCall: ${event.callUUID}');
  await TwilioProgrammableVoice.reject();
}

Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
  print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
}

void onPushKitToken(CallKeepPushKitToken event) {
  print('[onPushKitToken] token => ${event.token}');
}