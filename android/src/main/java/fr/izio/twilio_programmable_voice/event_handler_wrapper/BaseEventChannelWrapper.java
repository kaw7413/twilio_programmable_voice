package fr.izio.twilio_programmable_voice.event_handler_wrapper;

import android.util.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayDeque;

abstract class BaseEventChannelWrapper  implements EventChannel.StreamHandler {
    protected EventChannel eventChannel;
    protected EventChannel.EventSink eventSink;
    protected ArrayDeque<Object> queue;

    protected BaseEventChannelWrapper(EventChannel eventChannel) {
        Log.d("[BaseEventHandler]", "constructor called");
        this.eventChannel = eventChannel;
        queue = new ArrayDeque<>();
        if (eventChannel != null) {
            eventChannel.setStreamHandler(this);
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d("[BaseEventHandler]", "onListen called");
        eventSink = events;
        deQueue();
    }

    @Override
    public void onCancel(Object arguments) {
        Log.d("[BaseEventHandler]", "onCancel called");
        eventSink = null;
    }

//    This solution is great because it abstract the deQueue process
//    The problem is it's not type safe
    protected void deQueue() {
        Log.d("[BaseEventHandler]", "deQueue called");
        for (Object status : queue)
        {
            eventSink.success(status);
        }
    }

    protected Boolean send(Object data) {
        if (eventSink == null) {
            Log.d("[BaseEventHandler]", "eventSink is null, add data to queue");
            queue.add(data);
            return false;
        } else {
            eventSink.success(data);
            return true;
        }
    }

}
