import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';

part 'navigator_event.dart';

class NavigatorBloc extends Bloc<NavigatorEvent, dynamic> {
  final GlobalKey<NavigatorState> navigatorKey;
  NavigatorBloc({required this.navigatorKey}) : super(null);

  @override
  Stream<dynamic> mapEventToState(NavigatorEvent event) async* {
    if (event is NavigatorActionPop) {
      navigatorKey.currentState?.pop();
    } else if (event is NavigateToCallScreen) {
      navigatorKey.currentState?.pushNamed('/call');
    } else if (event is NavigateToHomeScreen) {
      navigatorKey.currentState?.pushNamed('/');
    }
  }
}
