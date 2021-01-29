import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import 'package:twilio_programmable_voice/src/token_service.dart';
import 'package:workmanager/workmanager.dart';
import 'box_service.dart';
import 'token_service.dart';

abstract class PluginServices {
  static const BoxService = "BoxService";
  static const TokenService = "TokenService";
  static const WorkManager = "Workmanager";
}

T getService<T>() {
  if (!GetIt.I.isRegistered<T>()) {
    GetIt.I.registerSingleton<T>(servicesFactory(T.toString()));
  }

  return GetIt.I<T>();
}

dynamic servicesFactory(String type) {
  switch (type) {
    case PluginServices.BoxService:
      return BoxService();
    case PluginServices.TokenService:
      return TokenService();
    case PluginServices.WorkManager:
      return Workmanager();
    default:
      throw ('You try to instantiate a non existing service');
  }
}

@visibleForTesting
void mockService<T>({@required T mock}) {
  if (GetIt.I.isRegistered<T>()) {
    GetIt.I.unregister<T>();
  }

  GetIt.I.registerSingleton<T>(mock);
}
