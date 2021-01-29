import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:twilio_programmable_voice/src/callback_dispatcher.dart';
import 'package:twilio_programmable_voice/src/injector.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerMock extends Mock implements Workmanager {}

void main() {
  setUpAll(() {
    mockService<Workmanager>(mock: WorkmanagerMock());
  });

  test(
      'callbackDispatcher should call Workmanager.executeTask with the taskHandler',
      () {
    expect(callbackDispatcher, isA<Function>());
    callbackDispatcher();
    verify(getService<Workmanager>().executeTask(taskHandler));
  });
}
