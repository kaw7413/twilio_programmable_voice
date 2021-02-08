import 'package:flutter_test/flutter_test.dart';

import 'package:twilio_programmable_voice/src/events.dart';

void main() {
  group('CallInvite and CancelledCallInvite', () {
    Map<String, String> mapCallInvite = {"from": "CallInviteFrom", "to": "CallInviteTo", "sid": "CallInviteCallSid"};
    Map<String, String> mapCancelledCallInvite = {"from": "CancelledCallInviteFrom", "to": "CancelledCallInviteTo", "sid": "CancelledCallInviteCallSid"};

    test('from method in CallInvite class should hydrate a CallInvite object', () {
      CallInvite callInvite = CallInvite.from(mapCallInvite);
      expect(callInvite.runtimeType, CallInvite);
      expect(callInvite.from, mapCallInvite['from']);
      expect(callInvite.to, mapCallInvite['to']);
      expect(callInvite.sid, mapCallInvite['callSid']);
    });

    test('from method in CancelledCallInvite class should hydrate a CancelledCallInvite object', () {
      CancelledCallInvite cancelledCallInvite = CancelledCallInvite.from(mapCancelledCallInvite);
      expect(cancelledCallInvite.runtimeType, CancelledCallInvite);
      expect(cancelledCallInvite.from, mapCancelledCallInvite['from']);
      expect(cancelledCallInvite.to, mapCancelledCallInvite['to']);
      expect(cancelledCallInvite.sid, mapCancelledCallInvite['callSid']);
    });
  });

  group('Other Call', () {
    Map<String, dynamic> mapCall = {"from": "CallFrom", "to": "CallTo", "sid": "sid", "state": "CallState", "isMuted": false, "isOnHold": false};
    test('from method in CallConnectFailure class should hydrate a CallConnectFailure object', () {
      CallConnectFailure callConnectFailure = CallConnectFailure.from(mapCall);
      expect(callConnectFailure.runtimeType, CallConnectFailure);
      expect(callConnectFailure.from, mapCall["from"]);
      expect(callConnectFailure.to, mapCall["to"]);
      expect(callConnectFailure.sid, mapCall["sid"]);
      expect(callConnectFailure.state, mapCall["state"]);
      expect(callConnectFailure.isMuted, mapCall["isMuted"]);
      expect(callConnectFailure.isOnHold, mapCall["isOnHold"]);
    });

    test('from method in CallRinging class should hydrate a CallRinging object', () {
      CallRinging callRinging = CallRinging.from(mapCall);
      expect(callRinging.runtimeType, CallRinging);
      expect(callRinging.from, mapCall["from"]);
      expect(callRinging.to, mapCall["to"]);
      expect(callRinging.sid, mapCall["sid"]);
      expect(callRinging.state, mapCall["state"]);
      expect(callRinging.isMuted, mapCall["isMuted"]);
      expect(callRinging.isOnHold, mapCall["isOnHold"]);
    });

    test('from method in CallConnected class should hydrate a CallConnected object', () {
      CallConnected callConnected = CallConnected.from(mapCall);
      expect(callConnected.runtimeType, CallConnected);
      expect(callConnected.from, mapCall["from"]);
      expect(callConnected.to, mapCall["to"]);
      expect(callConnected.sid, mapCall["sid"]);
      expect(callConnected.state, mapCall["state"]);
      expect(callConnected.isMuted, mapCall["isMuted"]);
      expect(callConnected.isOnHold, mapCall["isOnHold"]);
    });

    test('from method in CallReconnecting class should hydrate a CallReconnecting object', () {
      CallReconnecting callReconnecting = CallReconnecting.from(mapCall);
      expect(callReconnecting.runtimeType, CallReconnecting);
      expect(callReconnecting.from, mapCall["from"]);
      expect(callReconnecting.to, mapCall["to"]);
      expect(callReconnecting.sid, mapCall["sid"]);
      expect(callReconnecting.state, mapCall["state"]);
      expect(callReconnecting.isMuted, mapCall["isMuted"]);
      expect(callReconnecting.isOnHold, mapCall["isOnHold"]);
    });

    test('from method in callReconnected class should hydrate a CallReconnected object', () {
      CallReconnected callReconnected = CallReconnected.from(mapCall);
      expect(callReconnected.runtimeType, CallReconnected);
      expect(callReconnected.from, mapCall["from"]);
      expect(callReconnected.to, mapCall["to"]);
      expect(callReconnected.sid, mapCall["sid"]);
      expect(callReconnected.state, mapCall["state"]);
      expect(callReconnected.isMuted, mapCall["isMuted"]);
      expect(callReconnected.isOnHold, mapCall["isOnHold"]);
    });

    test('from method in CallDisconnected class should hydrate a CallDisconnected object', () {
      CallDisconnected callDisconnected = CallDisconnected.from(mapCall);
      expect(callDisconnected.runtimeType, CallDisconnected);
      expect(callDisconnected.from, mapCall["from"]);
      expect(callDisconnected.to, mapCall["to"]);
      expect(callDisconnected.sid, mapCall["sid"]);
      expect(callDisconnected.state, mapCall["state"]);
      expect(callDisconnected.isMuted, mapCall["isMuted"]);
      expect(callDisconnected.isOnHold, mapCall["isOnHold"]);
    });

    test('from method in CallQualityWarningChanged class should hydrate a CallQualityWarningChanged object', () {
      CallQualityWarningChanged callQualityWarningChanged = CallQualityWarningChanged.from(mapCall);
      expect(callQualityWarningChanged.runtimeType, CallQualityWarningChanged);
      expect(callQualityWarningChanged.from, mapCall["from"]);
      expect(callQualityWarningChanged.to, mapCall["to"]);
      expect(callQualityWarningChanged.sid, mapCall["sid"]);
      expect(callQualityWarningChanged.state, mapCall["state"]);
      expect(callQualityWarningChanged.isMuted, mapCall["isMuted"]);
      expect(callQualityWarningChanged.isOnHold, mapCall["isOnHold"]);
    });
  });
}