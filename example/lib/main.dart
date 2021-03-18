import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twilio_programmable_voice_example/bloc/call_bloc.dart'
    as CallBloc;
import 'package:callkeep/callkeep.dart';

import 'package:twilio_programmable_voice_example/config/application.dart';
import 'package:twilio_programmable_voice_example/config/routes.dart';

final logger = Logger();
final FlutterCallkeep _callKeep = FlutterCallkeep();

void main() async {
  Logger.level = Level.debug;

  await DotEnv().load('.env');

  runApp(AppComponent());
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This function should ideally lives in a global widget.
  // We seted up here to simplyfy things.
  Future<void> setUpTwilioProgrammableVoice() async {
    await TwilioProgrammableVoice()
        .requestMicrophonePermissions()
        .then(logger.d);

    await _callKeep.setup(<String, dynamic>{
      'ios': {
        'appName': 'TPV Example',
      },
      'android': {
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      },
    });

    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
    if (!hasPhoneAccount) {
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }

    _callKeep.on(CallKeepPerformAnswerCallAction(),
        (CallKeepPerformAnswerCallAction event) async {
      print("${event.callUUID} answered.");

      // await _callKeep.startCall(event.callUUID, "number", "callerName");
      await _callKeep.setCurrentCallActive(event.callUUID);
      await _callKeep.reportConnectingOutgoingCallWithUUID(event.callUUID);

      await TwilioProgrammableVoice().answer();

      await _callKeep.reportConnectedOutgoingCallWithUUID(event.callUUID);
    });

    _callKeep.on(CallKeepPerformEndCallAction(), (event) async {
      await TwilioProgrammableVoice().hangout();
    });

    await DotEnv().load('.env');
    final accessTokenUrl = DotEnv().env['ACCESS_TOKEN_URL'];

    final String platform = Platform.isAndroid ? "android" : "ios";

    TwilioProgrammableVoice().callStatusStream.listen((event) async {
      if (event is CallInvite) {
        print("CallInvite");
        await _callKeep.displayIncomingCall(event.sid, "event.from",
            handleType: 'number', hasVideo: false);
      }

      if (event is CancelledCallInvite) {
        await _callKeep.endCall(event.sid);
      }

      if (event is CallConnected) {
        print("CallConnected");
        // await _callKeep.setCurrentCallActive(event.sid);
      }

      if (event is CallRinging) {
        print("CallRinging");
        // await _callKeep.startCall(event.sid, event.to, "callerName");
      }

      if (event is CallDisconnected) {
        print("CallDisconnected");
        await _callKeep.endCall(event.sid);
      }
    });

    TwilioProgrammableVoice().setUp(
        accessTokenUrl: accessTokenUrl + "/$platform",
        headers: {
          "TestHeader": "I'm a test header"
        }).then((isRegistrationValid) {
      logger.d("registration is valid: " + isRegistrationValid.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    setUpTwilioProgrammableVoice();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Twilio Programming Voice'),
          ),
          body: Column(
            children: [
              FlatButton(
                  onPressed: () async {
                    final hasSucceed = await TwilioProgrammableVoice()
                        .makeCall(from: "testId", to: "+33651727985");

                    print("Make call success state $hasSucceed");

                    // Notify BLoC we've emitted a call
                    // Note: we could have moved .makeCall call to BLoC
                    context.read<CallBloc.CallBloc>().add(
                        CallBloc.CallEmited(contactPerson: "+33651727985"));

                    Application.router.navigateTo(context, Routes.call);
                  },
                  child: Text('Make call')),
            ],
          )),
    );
  }
}

class AppComponent extends StatefulWidget {
  @override
  State createState() {
    return AppComponentState();
  }
}

class AppComponentState extends State<AppComponent> {
  AppComponentState() {
    final router = FluroRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        // BLoC is only here to have a call state.
        create: (BuildContext context) => CallBloc.CallBloc(),
        child: MaterialApp(
          title: 'Twilio Programming Voice',
          debugShowCheckedModeBanner: false,
          onGenerateRoute: Application.router.generator,
          initialRoute: Routes.root,
        ));
  }
}
