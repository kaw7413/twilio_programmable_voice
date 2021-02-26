abstract class CallEvent {
  String from;
  String to;
  String sid;
}

class CallInvite extends CallEvent {
  String from;
  String to;
  String sid;

  CallInvite.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['callSid'] as String;

}

class CancelledCallInvite extends CallEvent {
  String from;
  String to;
  String sid;

  CancelledCallInvite.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['callSid'] as String;
}

class CallConnectFailure extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallConnectFailure.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}

class CallRinging extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallRinging.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}

class CallConnected extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallConnected.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}

class CallReconnecting extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallReconnecting.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}

class CallReconnected extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallReconnected.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}

class CallDisconnected extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallDisconnected.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}

class CallQualityWarningChanged extends CallEvent {
  String from;
  String to;
  String sid;
  String state;
  bool isMuted;
  bool isOnHold;

  CallQualityWarningChanged.from(Map<dynamic, dynamic> data)
      : from = data['from'] as String,
        to = data['to'] as String,
        sid = data['sid'] as String,
        state = data['state'].toString(),
        isMuted = data['isMuted'] as bool,
        isOnHold = data['isOnHold'] as bool;
}