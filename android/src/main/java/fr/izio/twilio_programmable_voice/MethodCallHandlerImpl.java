package fr.izio.twilio_programmable_voice;

import androidx.annotation.NonNull;

import com.twilio.voice.AcceptOptions;
import com.twilio.voice.Call;
import com.twilio.voice.CallInvite;
import com.twilio.voice.ConnectOptions;
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.Voice;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {
    static final String REGISTRATION_ERROR_CODE = "1";
    static final String REGISTRATION_ERROR_MESSAGE = "Registration failed";
    final String TAG = "[TwilioProgrammableVoice - MethodCallHandlerImpl]";

    public TwilioProgrammableVoice twilioProgrammableVoice;

    public MethodCallHandlerImpl(TwilioProgrammableVoice twilioProgrammableVoice) {
        this.twilioProgrammableVoice = twilioProgrammableVoice;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d(TAG, "onMethodCall " + call.method);
        if (call.method.equals("registerVoice")) {
            final String accessToken = call.argument("accessToken");
            final String fcmToken = call.argument("fcmToken");
            this.registerVoice(accessToken, fcmToken, result);
        } else if (call.method.equals("makeCall")) {
            final String from = call.argument("from");
            final String to = call.argument("to");
            final String accessToken = call.argument("accessToken");
            this.makeCall(from, to, accessToken, result);
        } else if (call.method.equals("handleMessage")) {
            final Map<String, String> data = call.argument("messageData");
            this.handleMessage(data, result);
        } else if (call.method.equals("stopCall")) {
            this.stopCall(result);
        } else if (call.method.equals("answer")) {
            this.answer(result);
        } else if (call.method.equals("reject")) {
            this.reject(result);
        } else if (call.method.equals("getBatteryLevel")) {
            this.tmpTestToRemove(result);
        } else {
            result.notImplemented();
        }
    }

    private void tmpTestToRemove(MethodChannel.Result result) {
        result.success("TOTO");
    }

    private void stopCall(MethodChannel.Result result) {
        Call call = twilioProgrammableVoice.getCurrentCall();

        if (call != null) {
            call.disconnect();
            result.success(true);
        }
        result.success(false);
    }

    private void reject(MethodChannel.Result result) {
        CallInvite callInvite = twilioProgrammableVoice.getCurrentCallInvite();
        Call call = twilioProgrammableVoice.getCurrentCall();

        // @TODO: keep track of all active call invites / calls
        // And only cancel what the end-user need to cancel.
        if (call != null) {
            call.disconnect();
        }

        if (callInvite != null) {
            callInvite.reject(twilioProgrammableVoice.getActivity().getApplicationContext());
        }


        result.success(null);
    }

    private void answer(MethodChannel.Result result) {
        CallInvite callInvite = twilioProgrammableVoice.getCurrentCallInvite();

        AcceptOptions.Builder acceptOptionsBuilder = new AcceptOptions.Builder();
        AcceptOptions acceptOptions = acceptOptionsBuilder.build();

        Call call = callInvite.accept(twilioProgrammableVoice.getActivity().getApplicationContext(), acceptOptions, twilioProgrammableVoice);

        result.success(call.toString());
    }

    private void handleMessage(Map<String, String> data, MethodChannel.Result result) {
        if (data == null) {
            result.error("VALIDATION", "Missing messageData parameter", null);
            return;
        }

        Log.d(TAG, "onMethodCall - handleMessage " + data.toString());

        final boolean isValid = Voice.handleMessage(twilioProgrammableVoice.getActivity().getApplicationContext(), data, this.twilioProgrammableVoice);

        if (isValid) {
            result.success(isValid);
        } else {
            result.error("NOT_TWILIO_MESSAGE", "Message Data isn't a valid twilio message", null);
        }
    }

    private void makeCall(String from, String to, String accessToken, MethodChannel.Result result) {
        Log.d(TAG, "makeCall");

        Map<String, String> params = new HashMap<>();
        params.put("From", from);
        params.put("To", to);

        try {
            final ConnectOptions connectOptions = new ConnectOptions.Builder(accessToken)
                    .params(params)
                    .build();

            Voice.connect(this.twilioProgrammableVoice.getActivity().getApplicationContext(), connectOptions, this.twilioProgrammableVoice);
            result.success(true);
        } catch (SecurityException error) {
            Log.e("SecurityException throw", "Error was throw while connecting with twilio");
            result.success(false);
            throw error;
        }
    }

    private void registerVoice(String accessToken, String fcmToken, MethodChannel.Result result) {

        if (accessToken == null) {
            result.error("VALIDATION", "Missing accessToken parameter", null);
            return;
        }

        if (fcmToken == null) {
            result.error("VALIDATION", "Missing fcmToken parameter", null);
            return;
        }

        Voice.register(accessToken, Voice.RegistrationChannel.FCM, fcmToken, registrationListener(result));
    }

    private RegistrationListener registrationListener(MethodChannel.Result result) {
        return new RegistrationListener() {
            @Override
            public void onRegistered(@NonNull String accessToken, @NonNull String fcmToken) {
                Log.d(TAG, "Successfully registered FCM " + fcmToken);
                result.success(true);
            }

            @Override
            public void onError(@NonNull RegistrationException error,
                                @NonNull String accessToken,
                                @NonNull String fcmToken) {
                Log.d(TAG, "Error while registering " + error.getMessage());
                result.error(MethodCallHandlerImpl.REGISTRATION_ERROR_CODE, MethodCallHandlerImpl.REGISTRATION_ERROR_MESSAGE, null);
            }
        };
    }
}
