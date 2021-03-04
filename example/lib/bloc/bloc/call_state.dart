part of 'call_bloc.dart';

@immutable
abstract class CallState {}

class CallInitial extends CallState {}

class CallRinging extends CallState {
  final String uuid;
  final String startedAt;
  final String contactPerson;
  final String direction;

  CallRinging({this.uuid, this.startedAt, this.contactPerson, this.direction});
}

class CallInProgress extends CallState {
  final String uuid;
  final String startedAt;
  final String contactPerson;
  final String direction;

  CallInProgress(
      {this.uuid, this.startedAt, this.contactPerson, this.direction});
}
