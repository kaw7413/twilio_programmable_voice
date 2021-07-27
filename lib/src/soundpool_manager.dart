import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class SoundPoolManager {
  static final SoundPoolManager _instance = SoundPoolManager._internal();

  late Future _soundsLoaded;
  late Soundpool _pool;
  late int _incomingSoundId;
  late int _outgoingSoundId;
  late int _disconnectSoundId;
  int? _ringingStreamId;
  bool _isPlaying = false;

  factory SoundPoolManager() {
    return _instance;
  }

  SoundPoolManager._internal() {
    // Docs recommand to create one soundpool for StreamType
    _pool = Soundpool(streamType: StreamType.notification);
    _soundsLoaded = this._setSounds();
  }

  _setSounds() async {
    _incomingSoundId = await rootBundle
        .load("packages/twilio_programmable_voice/assets/sounds/incoming.wav")
        .then((ByteData soundData) {
      return _pool.load(soundData);
    });

    _outgoingSoundId = await rootBundle
        .load("packages/twilio_programmable_voice/assets/sounds/outgoing.wav")
        .then((ByteData soundData) {
      return _pool.load(soundData);
    });

    _disconnectSoundId = await rootBundle
        .load("packages/twilio_programmable_voice/assets/sounds/disconnect.wav")
        .then((ByteData soundData) {
      return _pool.load(soundData);
    });
  }

  playIncoming() async {
    if (!_isPlaying) {
      try {
        await initializationDone;
        _isPlaying = true;
        _ringingStreamId = await _pool.play(_incomingSoundId, repeat: -1);
      } catch (error) {
        print(error.toString());
      }
    }
  }

  playOutgoing() async {
    if (!_isPlaying) {
      try {
        await initializationDone;
        _isPlaying = true;
        _ringingStreamId = await _pool.play(_outgoingSoundId, repeat: -1);
      } catch (error) {
        print(error.toString());
      }
    }
  }

  playDisconnect() async {
    if (!_isPlaying) {
      try {
        await initializationDone;
        _pool.play(_disconnectSoundId);
      } catch (error) {
        print(error.toString());
      }
    }
  }

  stopRinging() {
    if (_isPlaying && _ringingStreamId != null) {
      _pool.stop(_ringingStreamId!);
      _isPlaying = false;
    }
  }

  static SoundPoolManager get instance => _instance;
  Future get initializationDone => _soundsLoaded;
}
