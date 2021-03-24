import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:callkeep/callkeep.dart';
import 'package:flutter_apns/flutter_apns.dart';
import 'package:get_it/get_it.dart';

import 'package:twilio_programmable_voice_example/bloc/call/call_bloc.dart'
as CallBloc;
import 'package:twilio_programmable_voice_example/background_message_handler.dart';
import 'package:twilio_programmable_voice_example/call_screen.dart';
import 'bloc/navigator/navigator_bloc.dart' as NB;

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

          await _callKeep.setCurrentCallActive(event.callUUID);
          await _callKeep.reportConnectingOutgoingCallWithUUID(event.callUUID);

          await TwilioProgrammableVoice().answer();

          await _callKeep.reportConnectedOutgoingCallWithUUID(event.callUUID);
        });

    _callKeep.on(CallKeepPerformEndCallAction(), (event) async {
      await TwilioProgrammableVoice().reject();
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
      }

      if (event is CallRinging) {
        print("CallRinging");
      }

      if (event is CallDisconnected) {
        print("CallDisconnected");
        await _callKeep.endCall(event.sid);
      }
    });

    // Background listener for android only
    final connector = createPushConnector();
    connector.configure(
      onLaunch: (data) => Future.microtask(() => print("onLaunch: $data")),
      onResume: (data) => Future.microtask(() => print("onResume : $data")),
      onMessage: (message) async {
        print("App onMessage Received");
      },
      onBackgroundMessage: Platform.isAndroid ? backgroundMessageHandler : null,
    );


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
                        .makeCall(from: "testId", to: "+33787934070");

                    print("Make call success state toto $hasSucceed");
                    GetIt.I<NB.NavigatorBloc>().add(NB.NavigateToCallScreen());
                    // Notify BLoC we've emitted a call
                    // Note: we could have moved .makeCall call to BLoC
                    context.read<CallBloc.CallBloc>().add(

                    CallBloc.CallEmited(contactPerson: "+3787934070"));
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  AppComponentState() {
    GetIt.I.registerSingleton<NB.NavigatorBloc>(NB.NavigatorBloc(navigatorKey: _navigatorKey));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        // BLoC is only here to have a call state.
        create: (BuildContext context) => CallBloc.CallBloc(),
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(),
            '/call': (context) => CallScreen(),
          },
          title: 'Twilio Programming Voice',
          debugShowCheckedModeBanner: false,
        ));
  }
}
