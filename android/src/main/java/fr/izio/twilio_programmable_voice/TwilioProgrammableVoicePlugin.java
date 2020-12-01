package fr.izio.twilio_programmable_voice;

import androidx.annotation.NonNull;

import com.twilio.voice.LogLevel;
import com.twilio.voice.Voice;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/** TwilioProgrammableVoicePlugin */
public class TwilioProgrammableVoicePlugin implements FlutterPlugin, ActivityAware {
  private LogLevel voiceLogLevel = LogLevel.DEBUG;

  private MethodChannel channel;
  private TwilioProgrammableVoice twilioProgrammableVoice = new TwilioProgrammableVoice();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "twilio_programmable_voice");
    channel.setMethodCallHandler(new MethodCallHandlerImpl(twilioProgrammableVoice));
    twilioProgrammableVoice.setChannel(channel);
    Voice.setLogLevel(voiceLogLevel);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.twilioProgrammableVoice.setActivity(binding.getActivity());
    this.twilioProgrammableVoice.registerVoiceReceiver(channel);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.twilioProgrammableVoice.setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.twilioProgrammableVoice.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    this.twilioProgrammableVoice.setActivity(null);
    this.twilioProgrammableVoice.unregisterVoiceReceiver();
  }
}
