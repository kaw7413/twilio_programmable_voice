package fr.izio.twilio_programmable_voice.event_handler_wrapper;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayDeque;

public class TwilioRegistrationEventChannelWrapper extends BaseEventChannelWrapper {
    public TwilioRegistrationEventChannelWrapper(EventChannel eventChannel) {
        super(eventChannel);
    }

    public void sendSuccess() {
        Log.d("[TwilioEventHandler]", "sendSuccess called");
        final Boolean data = true;
        if (isEventSinkHydrated(data)) {
            this.eventSink.success(data);
        }
    }

    public void sendFailure() {
        Log.d("[TwilioEventHandler]", "sendFailure called");
        final Boolean data = false;
        if (isEventSinkHydrated(data)) {
            this.eventSink.success(false);
        }
    }
}
