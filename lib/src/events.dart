abstract class CallEvent {
  String from;
  String to;
  String sid;

  CallEvent(this.from, this.to, this.sid);
}

class CallInvite extends CallEvent {
  CallInvite.from(Map<String, dynamic> data)
      : super(data['from'], data['to'], data['sid']);
}

class CancelledCallInvite extends CallEvent {
  CancelledCallInvite.from(Map<String, dynamic> data)
      : super(data['from'], data['to'], data['sid']);
}

class CallConnectFailure extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallConnectFailure.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}

class CallRinging extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallRinging.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}

class CallConnected extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallConnected.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}

class CallReconnecting extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallReconnecting.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}

class CallReconnected extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallReconnected.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}

class CallDisconnected extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallDisconnected.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}

class CallQualityWarningChanged extends CallEvent {
  String state;
  bool isMuted;
  bool isOnHold;

  CallQualityWarningChanged.from(Map<String, dynamic> data)
      : state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool,
        super(data['from'], data['to'], data['sid']);
}
