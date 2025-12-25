import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LocalizationProvider extends InheritedWidget {
  const LocalizationProvider({required super.child, required this.state, super.key});

  final LocalizedAppState state;

  static LocalizationProvider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<LocalizationProvider>())!;

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) => true;
}
