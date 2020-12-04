import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
// TODO load all sounds in constructor
class SoundPoolManager {
  Future _soundsLoaded;
  bool _isPlaying;
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
    // need to specify another function because the sound load async and contructor can't be async
    // _soundsLoaded = this._setSounds();
  }

  // load all the sounds but doesn't work
  // _setSounds() async {
    // this._ringingSoundId = await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/incoming.wav").then((ByteData soundData) {
    //   return _soundpool.load(soundData);
    // });
  // }

  playIncoming() async {
    if (!_isPlaying) {
      await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/incoming.wav").then((ByteData soundData) async {
        _isPlaying = true;
        _ringingStreamId = await _pool.loadAndPlay(soundData);
      });
    }

  }

  playOutgoing() async {
    if (!_isPlaying) {
      await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/outgoing.wav").then((ByteData soundData) async {
        _isPlaying = true;
        _ringingStreamId = await _pool.loadAndPlay(soundData);
      });
    }
  }

  playDisconnect() async {
    if (!_isPlaying) {
      await rootBundle.load("packages/twilio_programmable_voice/assets/sounds/disconnect.wav").then((ByteData soundData) {
        _isPlaying = false;
        _pool.loadAndPlay(soundData);
      });
    }
  }

  stopRinging() async {
    if (_isPlaying && _ringingStreamId != null) {
      _pool.stop(_ringingStreamId);
    }
  }



  // with this you can wait until all sounds are loaded;
  // await initializationDone.then(() {
  // //
  // });
  // Future get initializationDone => _soundsLoaded;

}