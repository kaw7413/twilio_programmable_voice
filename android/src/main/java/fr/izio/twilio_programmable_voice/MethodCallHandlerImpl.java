package fr.izio.twilio_programmable_voice;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.twilio.voice.Call;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.CancelledCallInvite;
import com.twilio.voice.MessageListener;
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.Voice;

import java.util.Locale;
import java.util.Map;
import java.util.Set;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

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

        } else if (call.method.equals("handleMessage")) {
            final Map<String, String> data = call.argument("messageData");

            if (data == null) {
                result.error("VALIDATION", "Missing messageData parameter", null);
                return;
            }

            Log.d(TAG, "onMethodCall - handleMessage " + data.toString());

            final boolean isValid = Voice.handleMessage(twilioProgrammableVoice.getActivity().getApplicationContext(), data, new MessageListener() {
                @Override
                public void onCallInvite(@NonNull CallInvite callInvite) {
                    Log.d(TAG, "onCallInvite: " + callInvite.toString());

                    result.success(callInvite.toString());
                }

                @Override
                public void onCancelledCallInvite(@NonNull CancelledCallInvite cancelledCallInvite, @Nullable CallException callException) {
                    Log.d(TAG, "onCancelledCallInvite: " + cancelledCallInvite.toString());

                    result.error("CANCELLED_CALL_INVITE", "Call invite cancelled", callException.toString());
                }
            });

            if (!isValid) {
                result.error("NOT_TWILIO_MESSAGE", "Message Data isn't a valid twilio message", null);
            }
        } else if (call.method.equals("getPlatformVersion")) {
            this.getPlatformVersion(result);
        } else {
            result.notImplemented();
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

    private Call.Listener callListener() {
        return new Call.Listener() {

            @Override
            public void onConnectFailure(@NonNull Call call, @NonNull CallException callException) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }

            @Override
            public void onRinging(@NonNull Call call) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }

            @Override
            public void onConnected(@NonNull Call call) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }

            @Override
            public void onReconnecting(@NonNull Call call, @NonNull CallException callException) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }

            @Override
            public void onReconnected(@NonNull Call call) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }

            @Override
            public void onDisconnected(@NonNull Call call, @Nullable CallException callException) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }

            @Override
            public void onCallQualityWarningsChanged(@NonNull Call call, @NonNull Set<Call.CallQualityWarning> currentWarnings, @NonNull Set<Call.CallQualityWarning> previousWarnings) {
                twilioProgrammableVoice.getChannel().invokeMethod("onCallStatusCallback", call.toString());
            }
        };
    }
}
