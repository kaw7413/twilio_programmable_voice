// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hive/hive.dart';
// import 'package:mockito/mockito.dart';
// import 'package:start_jwt/json_web_token.dart';
// import 'package:workmanager/workmanager.dart';

// import 'package:twilio_programmable_voice/src/box_utils.dart';
// import 'package:twilio_programmable_voice/src/box_service.dart';
// import 'package:twilio_programmable_voice/src/injector.dart';
// import 'package:twilio_programmable_voice/src/token_service.dart';
// import 'package:twilio_programmable_voice/src/twilio_programmable_voice.dart';

// class MockWorkmanager extends Mock implements Workmanager {}
// class MockTokenService extends Mock implements TokenService {}
// class MockBoxService extends Mock implements BoxService {}
// class MockBox extends Mock implements Box {}

// var mockWorkmanager = mockService<Workmanager>(mock: MockWorkmanager());
// var mockTokenService = mockService<TokenService>(mock: MockTokenService());
// var mockBoxService = mockService<BoxService>(mock: MockBoxService());
// var mockBox = MockBox();

// final int testExp = 1300819380;
// final jwt = new JsonWebTokenCodec(secret: "My secret key");
// final payload = {
//   'exp': testExp,
// };
// final token = jwt.encode(payload);

// void main() {
//   const MethodChannel channel = MethodChannel('twilio_programmable_voice');

//   TestWidgetsFlutterBinding.ensureInitialized();

//   setUp(() {
//     channel.setMockMethodCallHandler((MethodCall methodCall) async {
//       if (methodCall.method == 'registerVoice') {
//         if (methodCall.arguments["accessToken"] == "throw") {
//           throw Exception();
//         }
//         return true;
//       }

//       if (methodCall.method == 'answer') {
//         return "ok";
//       }

//       if (methodCall.method == 'handleMessage') {
//         return true;
//       }
//     });

//     mockWorkmanager = mockService<Workmanager>(mock: MockWorkmanager());
//     mockTokenService = mockService<TokenService>(mock: MockTokenService());
//     mockBox = MockBox();
//     mockBoxService = mockService<BoxService>(mock: MockBoxService());
//     when(mockBoxService.getBox()).thenAnswer((realInvocation)async  => mockBox);
//   });

//   tearDown(() {
//     channel.setMockMethodCallHandler(null);
//   });

//   test('singleton should be implemented', () {
//     expect(TwilioProgrammableVoice.instance, isA<TwilioProgrammableVoice>());
//   });

//   group('setup', () {
//     test('should return true if registration is valid', () async {

//       when(mockTokenService.getAccessToken(accessTokenUrl: anyNamed("accessTokenUrl"))).thenAnswer((realInvocation) async => token);
//       expect(await TwilioProgrammableVoice.instance.setUp(accessTokenUrl: "fakeAccessToken"), true);
//     });

//     test('should return false and delete the accesstoken in the box if anything fails during registration', () async {
//       when(mockTokenService.getAccessToken(accessTokenUrl: anyNamed("accessTokenUrl"))).thenAnswer((realInvocation) async => "throw");

//       expect(await TwilioProgrammableVoice.instance.setUp(accessTokenUrl: "fakeAccessToken"), false);
//       verify(mockBox.delete(BoxKeys.ACCESS_TOKEN));
//     });
//   });

//   group('makeCall', () {
//     test('should get the token from token service and call makeCall', () async {
//       when(mockTokenService.getAccessToken(accessTokenUrl: anyNamed("accessTokenUrl"))).thenAnswer((realInvocation) async => token);

//       await TwilioProgrammableVoice.instance.makeCall(from: "from", to: "to");

//       verify(mockTokenService.getAccessToken(accessTokenUrl: anyNamed("accessTokenUrl")));
//     });
//   });

//   group('answer', () {
//     test('it should return the method channel <String> response', () async {
//       expect(await TwilioProgrammableVoice.instance.answer(), "ok");
//     });
//   });

//   group('reject', () {
//     test('it should execute without exception', () async {
//       await TwilioProgrammableVoice.instance.reject();
//     });
//   });

//   group('handleMessage', () {
//     test('it should return the method channel <Boolean> response', () async {
//       expect(await TwilioProgrammableVoice.instance.handleMessage(data: {}), true);
//     });
//   });
// }
