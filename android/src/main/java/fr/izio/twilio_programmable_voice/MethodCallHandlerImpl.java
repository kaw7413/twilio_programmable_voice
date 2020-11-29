package fr.izio.twilio_programmable_voice;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.twilio.voice.Call;
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.Voice;

import java.util.Locale;

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
        if (call.method.equals("getPlatformVersion")) {
            this.getPlatformVersion(result);
        } if (call.method.equals("registerVoice")) {
            final String accessToken = call.argument("accessToken");
            final String fcmToken = call.argument("fcmToken");

            this.registerVoice(accessToken, fcmToken, result);
        } else if (call.method.equals("getCallStatusListener")) {
            // return the receiver ? How to do that ? Maybe only send a stream ?
            result.success(twilioProgrammableVoice.voiceBroadcastReceiver);
        } else if (call.method.equals("getPlatformVersion")) {
            this.getPlatformVersion(result);
        } else {
            result.notImplemented();
        }
    }

    private void registerVoice(String accessToken, String fcmToken, MethodChannel.Result result) {

        if (accessToken == null) {
            result.error("VALIDATION", "Missing accessToken parameter", null);
        }

        if (fcmToken == null) {
            result.error("VALIDATION", "Missing fcmToken parameter", null);
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
