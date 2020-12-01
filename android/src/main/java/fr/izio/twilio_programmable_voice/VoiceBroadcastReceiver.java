package fr.izio.twilio_programmable_voice;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import io.flutter.plugin.common.MethodChannel;

public class VoiceBroadcastReceiver extends BroadcastReceiver {

    public String TAG = "VoiceBroadcastReceiver";
    private MethodChannel channel;

    VoiceBroadcastReceiver(MethodChannel channel) {
        this.channel = channel;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Log.d(TAG, "Action: " + action);

        this.channel.invokeMethod("onCallStatusCallback", action);
    }
}