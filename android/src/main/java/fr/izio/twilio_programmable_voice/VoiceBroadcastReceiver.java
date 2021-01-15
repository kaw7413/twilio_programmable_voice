package fr.izio.twilio_programmable_voice;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
// TODO is this still used ? remove ?
public class VoiceBroadcastReceiver extends BroadcastReceiver {

    public String TAG = "VoiceBroadcastReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Log.d(TAG, "Action: " + action);
    }
}