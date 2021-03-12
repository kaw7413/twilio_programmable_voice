import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:twilio_programmable_voice_example/call_screen.dart';
import 'package:twilio_programmable_voice_example/main.dart';

class Routes {
  static String root = "/";
  static String call = "call";

  static Handler rootHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return HomePage();
  });

  static Handler callHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return CallScreen();
  });

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
      return;
    });
    router.define(root, handler: rootHandler);
    router.define(call, handler: callHandler);
  }
}
