part of 'navigator_bloc.dart';

@immutable
abstract class NavigatorEvent {}

class NavigatorActionPop extends NavigatorEvent { }
class NavigateToCallScreen extends NavigatorEvent { }
class NavigateToHomeScreen extends NavigatorEvent { }