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

import java.util.HashMap;
import java.util.Set;

import fr.izio.twilio_programmable_voice.event_handler_wrapper.CallStatusEventChannelWrapper;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class TwilioProgrammableVoice implements MessageListener, Call.Listener {
    private Activity activity;
    private MethodChannel channel;
    private CallInvite currentCallInvite;
    private Call currentCall;
    private CallStatusEventChannelWrapper callStatusEventChannelWrapper;

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

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("ACTION_INCOMING_CALL");
        intentFilter.addAction("ACTION_CANCEL_CALL");
        intentFilter.addAction("ACTION_FCM_TOKEN");
    }

    public void setCurrentCallInvite(CallInvite currentCallInvite) {
        this.currentCallInvite = currentCallInvite;
        callStatusEventChannelWrapper.sendCallInvite(getCallInvitePayload(currentCallInvite));
    }

    public void setCurrentCancelledCallInvite(CancelledCallInvite currentCancelledCallInvite) {
        callStatusEventChannelWrapper.sendCancelledCallInvite(getCancelledCallInvite(currentCancelledCallInvite));
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
    public void onConnectFailure(@NonNull Call call, @NonNull CallException callException) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallConnectFailure(getCallPayload(call, TwilioProgrammableVoice.CALL_CONNECT_FAILURE));
    }

    @Override
    public void onRinging(@NonNull Call call) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallRinging(getCallPayload(call, TwilioProgrammableVoice.CALL_RINGING));
    }

    @Override
    public void onConnected(@NonNull Call call) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallConnected(getCallPayload(call, TwilioProgrammableVoice.CALL_CONNECTED));
    }

    @Override
    public void onReconnecting(@NonNull Call call, @NonNull CallException callException) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallReconnecting(getCallPayload(call, TwilioProgrammableVoice.CALL_RECONNECTING));
    }

    @Override
    public void onReconnected(@NonNull Call call) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallReconnected(getCallPayload(call, TwilioProgrammableVoice.CALL_RECONNECTED));
    }

    @Override
    public void onDisconnected(@NonNull Call call, @Nullable CallException callException) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallDisconnected(getCallPayload(call, TwilioProgrammableVoice.CALL_DISCONNECTED));
    }

    @Override
    public void onCallQualityWarningsChanged(@NonNull Call call, @NonNull Set<Call.CallQualityWarning> currentWarnings, @NonNull Set<Call.CallQualityWarning> previousWarnings) {
        setCurrentCall(call);
        callStatusEventChannelWrapper.sendCallQualityWarningsChanged(getCallPayload(call, TwilioProgrammableVoice.CALL_QUALITY_WARNING_CHANGED));
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

    public void setCallStatusEventChannelWrapper(EventChannel callStatusEventChannel) {
        this.callStatusEventChannelWrapper = new CallStatusEventChannelWrapper(callStatusEventChannel);
    }

    public CallInvite getCurrentCallInvite() {
        return currentCallInvite;
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
