import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twilio_programmable_voice_example/config/application.dart';
import 'package:twilio_programmable_voice_example/config/routes.dart';
import 'package:twilio_programmable_voice_example/widgets/dial_button.dart';
import 'package:twilio_programmable_voice_example/widgets/dial_user_picture.dart';
import 'package:twilio_programmable_voice_example/widgets/rounded_button.dart';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Anna williams",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.white),
              ),
              Text(
                "Calling…",
                style: TextStyle(color: Colors.white60),
              ),
              SizedBox(height: 5),
              DialUserPicture(image: "assets/images/calling_face.png"),
              Spacer(),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  DialButton(
                    iconSrc: "assets/icons/Icon Mic.svg",
                    text: "Audio",
                    press: () {},
                  ),
                  DialButton(
                    iconSrc: "assets/icons/Icon Volume.svg",
                    text: "Microphone",
                    press: () {},
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
                press: () {
                  Application.router.navigateTo(context, Routes.root);
                },
                color: Colors.red.shade300,
                iconColor: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
