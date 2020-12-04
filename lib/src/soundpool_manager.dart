import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class SoundPoolManager {
  Future _soundsLoaded;
  bool _isPlaying = false;
  int _incomingSoundId;
  int _outgoingSoundId;
  int _disconnectSoundId;
  int _ringingStreamId;
  Soundpool _pool;
  static SoundPoolManager _instance;

  static SoundPoolManager getInstance() {
    if (_instance == null) {
      _instance = SoundPoolManager._internal();
    }

    return _instance;
  }
  SoundPoolManager._internal() {
    // Docs recommand to create one soundpool for StreamType
    _pool = Soundpool(streamType: StreamType.notification);
    _soundsLoaded = this._setSounds();
  }

  _setSounds() async {
    _incomingSoundId = await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/incoming.wav").then((ByteData soundData) {
      return _pool.load(soundData);
    });

    _outgoingSoundId = await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/outgoing.wav").then((ByteData soundData) {
      return _pool.load(soundData);
    });

    _disconnectSoundId = await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/disconnect.wav").then((ByteData soundData) {
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
      _pool.stop(_ringingStreamId);
      _isPlaying = false;
    }
  }

  Future get initializationDone => _soundsLoaded;
}