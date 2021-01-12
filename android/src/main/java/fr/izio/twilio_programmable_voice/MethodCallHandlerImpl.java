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

    final String TAG = "[TwilioProgrammableVoice - MethodCallHandlerImpl]";

    // TODO make this persistent and remove class attribute
    private String accessToken;
    public TwilioProgrammableVoice twilioProgrammableVoice;

    public MethodCallHandlerImpl(TwilioProgrammableVoice twilioProgrammableVoice) {
        this.twilioProgrammableVoice = twilioProgrammableVoice;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d(TAG, "onMethodCall " + call.method);
        switch (call.method) {
            case "registerVoice":
                final String accessToken = call.argument("accessToken");
                final String fcmToken = call.argument("fcmToken");

                this.registerVoice(accessToken, fcmToken, result);
                break;

            case "handleMessage":
                final Map<String, String> data = call.argument("messageData");

                this.handleMessage(data, result);
                break;

            case "makeCall":
                final String from = call.argument("from");
                final String to = call.argument("to");

                this.makeCall(from, to, result);
                break;

            case "answer":
                this.answer(result);
                break;

            case "reject":
                this.reject(result);
                break;

            case "getPlatformVersion":
                this.getPlatformVersion(result);
                break;

            default:
                result.notImplemented();
                break;
        }
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

        if (!isValid) {
            result.error("NOT_TWILIO_MESSAGE", "Message Data isn't a valid twilio message", null);
            return;
        }

        result.success(true);
    }

    private void makeCall(String from, String to, MethodChannel.Result result) {
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

        //TODO remove this line when access token is persistent
        this.accessToken = accessToken;
        Voice.register(accessToken, Voice.RegistrationChannel.FCM, fcmToken, registrationListener(result));
    }

    private void getPlatformVersion(MethodChannel.Result result) {
        final String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;

        result.success(platformVersion);
    }

    private RegistrationListener registrationListener(MethodChannel.Result result) {
        return new RegistrationListener() {
            @Override
            public void onRegistered(@NonNull String accessToken, @NonNull String fcmToken) {
                Log.d(TAG, "Successfully registered FCM " + fcmToken);

                // @TODO: probably call this when a call is accepted ?
                // Bind call listener to the application context.
                // Voice.connect(twilioProgrammableVoice.getActivity().getApplicationContext(), accessToken, callListener());

                // Maybe return the token that got registered ?
                result.success(null);
            }

            @Override
            public void onError(@NonNull RegistrationException error,
                                @NonNull String accessToken,
                                @NonNull String fcmToken) {
                String message = String.format(
                        Locale.US,
                        "Registration Error: %d, %s",
                        error.getErrorCode(),
                        error.getMessage());

                result.error("REGISTRATION_ERROR", message, error);
            }
        };
    }
}
