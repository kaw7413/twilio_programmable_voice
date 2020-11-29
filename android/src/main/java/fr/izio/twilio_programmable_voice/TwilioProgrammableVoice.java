package fr.izio.twilio_programmable_voice;

import android.app.Activity;
import android.content.IntentFilter;

import com.twilio.voice.Call;
import com.twilio.voice.CallInvite;

public class TwilioProgrammableVoice {
    private static final String TAG = "TwilioProgrammableVoice";

    private Activity activity;
    public VoiceBroadcastReceiver voiceBroadcastReceiver;

    private CallInvite activeCallInvite;
    private Call activeCall;
    private int activeCallNotificationId;

    TwilioProgrammableVoice() {}

    public void registerVoiceReceiver() {
        this.voiceBroadcastReceiver = new VoiceBroadcastReceiver();

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
}
