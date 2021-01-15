package fr.izio.twilio_programmable_voice.event_handler_wrapper;

import android.util.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;

public class CallStatusEventChannelWrapper extends BaseEventChannelWrapper {
    public CallStatusEventChannelWrapper(EventChannel eventChannel) {
        super(eventChannel);
    }

    public void sendCallInvite(HashMap<String, String> callInvite) {
        Log.d("[CallEventHandler]", "sendCallInvite called");
        if (isEventSinkHydrated(callInvite)) {
            eventSink.success(callInvite);
        }
    }

    public void sendCancelledCallInvite(HashMap<String, String> cancelledCallInvite) {
        Log.d("[CallEventHandler]", "sendCancelledCallInvite called");
        if (isEventSinkHydrated(cancelledCallInvite)) {
            eventSink.success(cancelledCallInvite);
        }
    }

    public void sendCallConnectFailure(HashMap<String, Object> callConnectFailure) {
        Log.d("[CallEventHandler]", "sendCallConnectFailure called");
        if (isEventSinkHydrated(callConnectFailure)) {
            eventSink.success(callConnectFailure);
        }
    }

    public void sendCallRinging(HashMap<String, Object> callRinging) {
        Log.d("[CallEventHandler]", "sendCallRinging called");
        if (isEventSinkHydrated(callRinging)) {
            eventSink.success(callRinging);
        }
    }

    public void sendCallConnected(HashMap<String, Object> callConnected) {
        Log.d("[CallEventHandler]", "sendCallConnected called");
        if (isEventSinkHydrated(callConnected)) {
            eventSink.success(callConnected);
        }
    }

    public void sendCallReconnecting(HashMap<String, Object> callReconnecting) {
        Log.d("[CallEventHandler]", "sendSuccess called");
        if (isEventSinkHydrated(callReconnecting)) {
            eventSink.success(callReconnecting);
        }
    }

    public void sendCallReconnected(HashMap<String, Object> callReconnected) {
        Log.d("[CallEventHandler]", "sendCallReconnected called");
        if (isEventSinkHydrated(callReconnected)) {
            eventSink.success(callReconnected);
        }
    }

    public void sendCallDisconnected(HashMap<String, Object> callDisconnected) {
        Log.d("[CallEventHandler]", "sendCallDisconnected called");
        if (isEventSinkHydrated(callDisconnected)) {
            eventSink.success(callDisconnected);
        }
    }

    public void sendCallQualityWarningsChanged(HashMap<String, Object> callQualityWarningsChanged) {
        Log.d("[CallEventHandler]", "sendCallQualityWarningsChanged called");
        if (isEventSinkHydrated(callQualityWarningsChanged)) {
            eventSink.success(callQualityWarningsChanged);
        }
    }

}
