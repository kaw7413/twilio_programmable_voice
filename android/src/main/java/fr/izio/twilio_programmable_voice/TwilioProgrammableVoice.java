package fr.izio.twilio_programmable_voice;

import android.app.Activity;
import android.content.IntentFilter;

import io.flutter.plugin.common.MethodChannel;

public class TwilioProgrammableVoice {
    private static final String TAG = "TwilioProgrammableVoice";

    private Activity activity;
    public VoiceBroadcastReceiver voiceBroadcastReceiver;
    private MethodChannel channel;

    public void registerVoiceReceiver(MethodChannel channel) {
        this.voiceBroadcastReceiver = new VoiceBroadcastReceiver(channel);

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("ACTION_INCOMING_CALL");
        intentFilter.addAction("ACTION_CANCEL_CALL");
        intentFilter.addAction("ACTION_FCM_TOKEN");

        // Register the receiver at application context.
        this.activity.getApplicationContext().registerReceiver(this.voiceBroadcastReceiver, intentFilter);
    }

    public void unregisterVoiceReceiver() {
        this.activity.getApplicationContext().unregisterReceiver(this.voiceBroadcastReceiver);
    }

    public Activity getActivity() {
        return activity;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public void setChannel(MethodChannel channel) {
        this.channel = channel;
    }

    public MethodChannel getChannel() {
        return this.channel;
    }
}
