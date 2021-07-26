part of 'call_bloc.dart';

@immutable
abstract class CallState {}

class CallInitial extends CallState {}

class CallRinging extends CallState {
  final String uuid;
  final String startedAt;
  final String contactPerson;
  final String direction;

  CallRinging(
      {required this.uuid,
      required this.startedAt,
      required this.contactPerson,
      required this.direction});
}

class CallInProgress extends CallState {
  final String uuid;
  final String startedAt;
  final String contactPerson;
  final String direction;

  final bool? isMuted;
  final bool? isHold;
  final bool? isAudioRoutedToSpeaker;

  CallInProgress(
      {required this.uuid,
      required this.startedAt,
      required this.contactPerson,
      required this.direction,
      this.isAudioRoutedToSpeaker,
      this.isHold,
      this.isMuted});

  CallInProgress copyWith(
      {bool? isHold, bool? isMuted, bool? isAutioRoutedToSpeaker}) {
    return CallInProgress(
      uuid: this.uuid,
      startedAt: this.startedAt,
      contactPerson: this.contactPerson,
      direction: this.direction,
      isMuted: isMuted ?? this.isMuted,
      isHold: isHold ?? this.isHold,
      isAudioRoutedToSpeaker:
          isAudioRoutedToSpeaker ?? this.isAudioRoutedToSpeaker,
    );
  }
}
