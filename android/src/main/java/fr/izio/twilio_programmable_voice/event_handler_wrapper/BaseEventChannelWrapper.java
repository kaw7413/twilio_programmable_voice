package fr.izio.twilio_programmable_voice.event_handler_wrapper;

import io.flutter.Log;
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

    protected void send(Object data) {
        Log.d("[BaseEventHandler]", "send called");
        if (eventSink != null) {
            Log.d("[BaseEventHandler]", "send data throught eventSink");
            eventSink.success(data);
        } else {
            Log.d("[BaseEventHandler]", "add data to queue");
            queue.add(data);
        }
    }

    private void deQueue() {
        Log.d("[BaseEventHandler]", "deQueue called");
        for (Object status : queue)
        {
            eventSink.success(status);
        }
    }
}
