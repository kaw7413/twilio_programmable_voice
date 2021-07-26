import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart'
    as TPV;
import 'bloc/navigator/navigator_bloc.dart' as NB;
import 'package:twilio_programmable_voice_example/bloc/call/call_bloc.dart';
import 'package:twilio_programmable_voice_example/widgets/dial_button.dart';
import 'package:twilio_programmable_voice_example/widgets/dial_user_picture.dart';
import 'package:twilio_programmable_voice_example/widgets/rounded_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class CallScreen extends StatelessWidget {
  Widget displayStateText(CallState state) {
    String text;

    if (state is CallRinging) {
      text = "Calling...";
    } else if (state is CallInProgress) {
      text = "Call In Progress...";
    } else {
      text = "Call Ended";
    }

    return Text(
      text,
      style: TextStyle(color: Colors.white60),
    );
  }

  String getContactPerson(CallState state) {
    if (state is CallRinging) {
      return state.contactPerson;
    } else if (state is CallInProgress) {
      return state.contactPerson;
    } else {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallBloc, CallState>(
      listener: (context, state) {
        print(state);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.blueGrey,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    this.getContactPerson(state),
                    style: TextStyle(color: Colors.white),
                  ),
                  this.displayStateText(state),
                  SizedBox(height: 5),
                  DialUserPicture(image: "assets/images/calling_face.png"),
                  Spacer(),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      DialButton(
                        iconSrc: "assets/icons/Icon Mic.svg",
                        text: "Audio",
                        press: () {
                          context
                              .read<CallBloc>()
                              .add(CallToggleMute(setOn: true));
                        },
                      ),
                      DialButton(
                        iconSrc: "assets/icons/Icon Volume.svg",
                        text: "Microphone",
                        press: () {
                          context
                              .read<CallBloc>()
                              .add(CallToggleSpeaker(setOn: true));
                        },
                      ),
                      DialButton(
                        iconSrc: "assets/icons/Icon Video.svg",
                        text: "Video",
                        press: () {},
                      ),
                      DialButton(
                        iconSrc: "assets/icons/Icon Message.svg",
                        text: "Message",
                        press: () {},
                      ),
                      DialButton(
                        iconSrc: "assets/icons/Icon User.svg",
                        text: "Add contact",
                        press: () {},
                      ),
                      DialButton(
                        iconSrc: "assets/icons/Icon Voicemail.svg",
                        text: "Voice mail",
                        press: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  RoundedButton(
                    iconSrc: "assets/icons/call_end.svg",
                    press: () async {
                      await TPV.TwilioProgrammableVoice().reject();

                      // NavigationPop here doesn't work, it's a problem
                      GetIt.I<NB.NavigatorBloc>()
                          .add(NB.NavigateToHomeScreen());
                    },
                    color: Colors.red.shade300,
                    iconColor: Colors.white,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
