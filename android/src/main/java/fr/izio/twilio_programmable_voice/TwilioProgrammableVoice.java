package fr.izio.twilio_programmable_voice;

import android.app.Activity;
import android.content.IntentFilter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.twilio.voice.Call;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.CancelledCallInvite;
import com.twilio.voice.MessageListener;

import java.util.Set;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class TwilioProgrammableVoice implements MessageListener, EventChannel.StreamHandler, Call.Listener {
    private static final String TAG = "TwilioProgrammableVoice";

    private Activity activity;
    public VoiceBroadcastReceiver voiceBroadcastReceiver;
    private MethodChannel channel;

    private CallInvite currentCallInvite;
    private CancelledCallInvite currentCancelledCallInvite;

    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

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

    public void setChannel(MethodChannel channel) {
        this.channel = channel;
    }

    public MethodChannel getChannel() {
        return this.channel;
    }

    public EventChannel getEventChannel() {
        return eventChannel;
    }

    public void setEventChannel(EventChannel eventChannel) {
        this.eventChannel = eventChannel;

        if (eventChannel != null) {
            eventChannel.setStreamHandler(this);
        }
    }

    public CallInvite getCurrentCallInvite() {
        return currentCallInvite;
    }

    public void setCurrentCallInvite(CallInvite currentCallInvite) {
        this.currentCallInvite = currentCallInvite;

        if (eventSink != null && currentCallInvite != null) {
            eventSink.success(currentCallInvite.toString());
            SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playRinging();
        }
    }

    public CancelledCallInvite getCurrentCancelledCallInvite() {
        return currentCancelledCallInvite;
    }

    public void setCurrentCancelledCallInvite(CancelledCallInvite currentCancelledCallInvite) {
        this.currentCancelledCallInvite = currentCancelledCallInvite;

        if (eventSink != null && currentCancelledCallInvite != null) {
            eventSink.success(currentCancelledCallInvite.toString());
            SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).stopRinging();
            SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playDisconnect();
        }
    }

    @Override
    public void onCallInvite(@NonNull CallInvite callInvite) {
        setCurrentCallInvite(callInvite);
    }

    @Override
    public void onCancelledCallInvite(@NonNull CancelledCallInvite cancelledCallInvite, @Nullable CallException callException) {
        setCurrentCancelledCallInvite(cancelledCallInvite);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    @Override
    public void onConnectFailure(@NonNull Call call, @NonNull CallException callException) {
        eventSink.success(call.toString());
        SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).stopRinging();
    }

    @Override
    public void onRinging(@NonNull Call call) {
        eventSink.success(call.toString());
        SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playRinging();
    }

    @Override
    public void onConnected(@NonNull Call call) {
        eventSink.success(call.toString());
        SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).stopRinging();
    }

    @Override
    public void onReconnecting(@NonNull Call call, @NonNull CallException callException) {
        eventSink.success(call.toString());
    }

    @Override
    public void onReconnected(@NonNull Call call) {
        eventSink.success(call.toString());
    }

    @Override
    public void onDisconnected(@NonNull Call call, @Nullable CallException callException) {
        eventSink.success(call.toString());
        SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playDisconnect();
    }

    @Override
    public void onCallQualityWarningsChanged(@NonNull Call call, @NonNull Set<Call.CallQualityWarning> currentWarnings, @NonNull Set<Call.CallQualityWarning> previousWarnings) {
        eventSink.success(call.toString());
    }
}
