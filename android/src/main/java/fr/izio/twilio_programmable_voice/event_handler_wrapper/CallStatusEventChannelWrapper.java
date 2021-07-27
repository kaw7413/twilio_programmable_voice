package fr.izio.twilio_programmable_voice.event_handler_wrapper;

import android.util.Log;

import org.json.JSONObject;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;

public class CallStatusEventChannelWrapper extends BaseEventChannelWrapper {

    public CallStatusEventChannelWrapper(EventChannel eventChannel) {
        super(eventChannel);
    }

    public void sendCallInvite(HashMap<String, String> callInvite) {
        Log.d("[CallEventHandler]", "sendCallInvite called");
        send(new JSONObject(callInvite).toString());
    }

    public void sendCancelledCallInvite(HashMap<String, String> cancelledCallInvite) {
        Log.d("[CallEventHandler]", "sendCancelledCallInvite called");
        send(new JSONObject(cancelledCallInvite).toString());
    }

    public void sendCallConnectFailure(HashMap<String, Object> callConnectFailure) {
        Log.d("[CallEventHandler]", "sendCallConnectFailure called");
        send(new JSONObject(callConnectFailure).toString());
    }

    public void sendCallRinging(HashMap<String, Object> callRinging) {
        Log.d("[CallEventHandler]", "sendCallRinging called");
        send(new JSONObject(callRinging).toString());
    }

    public void sendCallConnected(HashMap<String, Object> callConnected) {
        Log.d("[CallEventHandler]", "sendCallConnected called");
        send(new JSONObject(callConnected).toString());
    }

    public void sendCallReconnecting(HashMap<String, Object> callReconnecting) {
        Log.d("[CallEventHandler]", "sendSuccess called");
        send(new JSONObject(callReconnecting).toString());
    }

    public void sendCallReconnected(HashMap<String, Object> callReconnected) {
        Log.d("[CallEventHandler]", "sendCallReconnected called");
        send(new JSONObject(callReconnected).toString());
    }

    public void sendCallDisconnected(HashMap<String, Object> callDisconnected) {
        Log.d("[CallEventHandler]", "sendCallDisconnected called");
        send(new JSONObject(callDisconnected).toString());
    }

    public void sendCallQualityWarningsChanged(HashMap<String, Object> callQualityWarningsChanged) {
        Log.d("[CallEventHandler]", "sendCallQualityWarningsChanged called");
        send(new JSONObject(callQualityWarningsChanged).toString());
    }

}
