import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_translate/src/constants/constants.dart';
import 'package:flutter_translate/src/services/locale_service.dart';
import 'package:flutter_translate/src/validators/configuration_validator.dart';

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  LocalizationDelegate._(
    this.fallbackLocale,
    this.supportedLocales,
    this.supportedLocalesMap,
    this.preferences,
    this._stringProcessor,
    this._pluralProcessor,
  );

  Locale? _currentLocale;

  final Locale fallbackLocale;

  final List<Locale> supportedLocales;

  final Map<Locale, String> supportedLocalesMap;

  final ITranslatePreferences? preferences;

  LocaleChangedCallback? onLocaleChanged;

  String Function(String value, String key, String arg)? _stringProcessor;
  String Function(String value, String key, String arg)? _pluralProcessor;

  Locale get currentLocale => _currentLocale!;

  Future changeLocale(Locale newLocale) async {
    bool isInitializing = _currentLocale == null;

    Locale locale = LocaleService.findLocale(newLocale, supportedLocales) ?? fallbackLocale;

    if (_currentLocale == locale) {
      return;
    }

    Map<String, dynamic> localizedContent = await LocaleService.getLocaleContent(locale, supportedLocalesMap);

    Localization.load(localizedContent, _stringProcessor, _pluralProcessor);

    _currentLocale = locale;

    Intl.defaultLocale = _currentLocale?.languageCode;

    if (onLocaleChanged != null) {
      await onLocaleChanged!(locale);
    }

    if (!isInitializing && preferences != null) {
      await preferences!.savePreferredLocale(locale);
    }
  }

  @override
  Future<Localization> load(Locale newLocale) async {
    if (currentLocale != newLocale) {
      await changeLocale(newLocale);
    }

    return Localization.instance;
  }

  @override
  bool isSupported(Locale? locale) => locale != null;

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;

  static Future<LocalizationDelegate> create({
    required String fallbackLocale,
    required List<String> supportedLocales,
    String basePath = Constants.localizedAssetsPath,
    ITranslatePreferences? preferences,
    String Function(String value, String key, String arg)? keyProcessor,
    String Function(String value, String key, String arg)? pluralKeyProcessor,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    Locale fallback = localeFromString(fallbackLocale);
    Map<Locale, String> localesMap = await LocaleService.getLocalesMap(supportedLocales, basePath);
    List<Locale> locales = localesMap.keys.toList();

    ConfigurationValidator.validate(fallback, locales);

    LocalizationDelegate delegate = LocalizationDelegate._(
      fallback,
      locales,
      localesMap,
      preferences,
      keyProcessor,
      pluralKeyProcessor,
    );

    if (!await delegate._loadPreferences()) {
      await delegate._loadDeviceLocale();
    }

    return delegate;
  }

  Future<bool> _loadPreferences() async {
    if (preferences == null) {
      return false;
    }

    try {
      Locale? locale = await preferences!.getPreferredLocale();
      if (locale != null) {
        await changeLocale(locale);
      }
      return true;
    } catch (e) {
      // ignore
    }
    return false;
  }

  Future _loadDeviceLocale() async {
    try {
      Locale? locale = getCurrentLocale();
      if (locale != null) {
        await changeLocale(locale);
      }
    } catch (e) {
      await changeLocale(fallbackLocale);
    }
  }
}
