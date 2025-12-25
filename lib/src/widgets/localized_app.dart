import 'package:flutter/widgets.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LocalizedApp extends StatefulWidget {
  LocalizedApp(this.delegate, this.child);

  final Widget child;
  final LocalizationDelegate delegate;

  LocalizedAppState createState() => LocalizedAppState();

  static LocalizedApp of(BuildContext context) => context.findAncestorWidgetOfExactType<LocalizedApp>()!;
}

class LocalizedAppState extends State<LocalizedApp> {
  void onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) => LocalizationProvider(state: this, child: widget.child);
}
