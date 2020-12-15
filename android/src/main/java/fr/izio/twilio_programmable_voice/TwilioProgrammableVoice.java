package fr.izio.twilio_programmable_voice;

import android.app.Activity;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.twilio.voice.Call;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.CancelledCallInvite;
import com.twilio.voice.ConnectOptions;
import com.twilio.voice.MessageListener;
import com.twilio.voice.Voice;

import java.util.HashMap;
import java.util.Map;
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
    private Call currentCall;

    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    private static final String CALL_INVITE = "CallInvite";
    private static final String CANCELLED_CALL_INVITE = "CancelledCallInvite";
    private static final String CALL_CONNECT_FAILURE = "CallConnectFailure";
    private static final String CALL_RINGING = "CallRinging";
    private static final String CALL_CONNECTED = "CallConnected";
    private static final String CALL_RECONNECTING = "CallReconnecting";
    private static final String CALL_RECONNECTED = "CallReconnected";
    private static final String CALL_DISCONNECTED = "CallDisconnected";
    private static final String CALL_QUALITY_WARNING_CHANGED = "CallQualityWarningChanged";

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

    public void setCurrentCallInvite(CallInvite currentCallInvite) {
        this.currentCallInvite = currentCallInvite;

        if (eventSink != null && currentCallInvite != null) {

            eventSink.success(this.getCallInvitePayload(currentCallInvite));
            // SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playRinging();
        }
    }

    public void setCurrentCancelledCallInvite(CancelledCallInvite currentCancelledCallInvite) {
        this.currentCancelledCallInvite = currentCancelledCallInvite;

        if (eventSink != null && currentCancelledCallInvite != null) {
            eventSink.success(this.getCancelledCallInvite(currentCancelledCallInvite));
            // SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).stopRinging();
            // SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playDisconnect();
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
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_CONNECT_FAILURE));
        // SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).stopRinging();
    }

    @Override
    public void onRinging(@NonNull Call call) {
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_RINGING));
        // SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playRinging();
    }

    @Override
    public void onConnected(@NonNull Call call) {
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_CONNECTED));
        // SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).stopRinging();
    }

    @Override
    public void onReconnecting(@NonNull Call call, @NonNull CallException callException) {
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_RECONNECTING));
    }

    @Override
    public void onReconnected(@NonNull Call call) {
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_RECONNECTED));
    }

    @Override
    public void onDisconnected(@NonNull Call call, @Nullable CallException callException) {
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_DISCONNECTED));
//        SoundPoolManager.getInstance(this.getActivity().getApplicationContext()).playDisconnect();
    }

    @Override
    public void onCallQualityWarningsChanged(@NonNull Call call, @NonNull Set<Call.CallQualityWarning> currentWarnings, @NonNull Set<Call.CallQualityWarning> previousWarnings) {
        eventSink.success(this.getCallPayload(call, TwilioProgrammableVoice.CALL_QUALITY_WARNING_CHANGED));
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

    public CancelledCallInvite getCurrentCancelledCallInvite() {
        return currentCancelledCallInvite;
    }

    private HashMap<String, String> getCallInvitePayload(CallInvite callInvite) {
        HashMap<String, String> payload = new HashMap<>();
        payload.put("type", TwilioProgrammableVoice.CALL_INVITE);
        payload.put("from", callInvite.getFrom());
        payload.put("to", callInvite.getTo());
        payload.put("callSid", callInvite.getCallSid());

        return payload;
    }

    private HashMap<String, String> getCancelledCallInvite(CancelledCallInvite cancelledCallInvite) {
        HashMap<String, String> payload = new HashMap<>();
        payload.put("type", TwilioProgrammableVoice.CANCELLED_CALL_INVITE);
        payload.put("from", cancelledCallInvite.getFrom());
        payload.put("to", cancelledCallInvite.getTo());
        payload.put("callSid", cancelledCallInvite.getCallSid());

        return payload;
    }

    private HashMap<String, Object> getCallPayload(Call call, String type) {
        HashMap<String, Object> payload = new HashMap<>();
        payload.put("type", type);
        payload.put("from", call.getFrom());
        payload.put("to", call.getTo());
        payload.put("sid", call.getSid());
        payload.put("state", call.getState().toString());
        payload.put("isMuted", call.isMuted());
        payload.put("isOnHold", call.isOnHold());

        return payload;
    }

    public Call getCurrentCall() {
        return currentCall;
    }

    public void setCurrentCall(Call currentCall) {
        this.currentCall = currentCall;
    }
}
