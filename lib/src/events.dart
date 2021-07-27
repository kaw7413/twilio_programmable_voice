abstract class CallEvent {}

class CallInvite extends CallEvent {
  String sid;
  String type;
  String from;
  String to;

  CallInvite.from(Map<String, dynamic> data)
      : this.sid = data['callSid'],
        this.from = data['from'],
        this.to = data['to'],
        this.type = data['type'];
}

class CancelledCallInvite extends CallEvent {
  String sid;

  CancelledCallInvite.from(Map<String, dynamic> data)
      : this.sid = data['callSid'];
}

class CallConnectFailure extends CallEvent {
  CallConnectFailure.from(Map<String, dynamic> data);
}

class CallRinging extends CallEvent {
  CallRinging.from(Map<String, dynamic> data);
}

class CallConnected extends CallEvent {
  String sid;
  String? from;
  String? to;

  CallConnected.from(Map<String, dynamic> data)
      : this.sid = data['sid'],
        this.from = data['from'],
        this.to = data['to'];
}

class CallReconnecting extends CallEvent {
  CallReconnecting.from(Map<String, dynamic> data);
}

class CallReconnected extends CallEvent {
  CallReconnected.from(Map<String, dynamic> data);
}

class CallDisconnected extends CallEvent {
  String sid;

  CallDisconnected.from(Map<String, dynamic> data) : this.sid = data['sid'];
}

class CallQualityWarningChanged extends CallEvent {
  CallQualityWarningChanged.from(Map<String, dynamic> data);
}
