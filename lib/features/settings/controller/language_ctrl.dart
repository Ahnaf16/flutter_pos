// import 'package:flutter/material.dart';
// import 'package:khoroch/main.export.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'language_ctrl.g.dart';

// @riverpod
// class LanguageCtrl extends _$LanguageCtrl {
//   // use config
//   // final _sp = locate<SP>();

//   @override
//   Locale build() {
//     final locale = /* _sp.language.value ?? */ LangHelper.en;

//     return Locale.fromSubtags(languageCode: locale);
//   }

//   FVoid refresh() async {
//     ref.invalidateSelf();
//   }

//   FVoid setLocale(Locale locale) async {
//     LocaleSettings.setLocale(locale)
//     await TR.load(locale);
//     state = locale;
//     await _sp.language.setValue(locale.languageCode);
//     ref.invalidateSelf();
//   }

//   FVoid setFromCode(String? code) async {
//     if (code == null) return;
//     final locale = Locale.fromSubtags(languageCode: code);
//     await setLocale(locale);
//   }
// }

// typedef Lang = ({String key, String name});

// class LangHelper {
//   static String en = 'en';
//   static Locale enLocale = Locale(en);
//   static String nl = 'nl';
//   static Locale nlLocale = Locale(nl);

//   static final Map<Locale, Lang> _mapped = {enLocale: (key: en, name: 'English'), nlLocale: (key: nl, name: 'Dutch')};

//   static Lang getLang(Locale local) => _mapped[local] ?? _mapped.values.first;
// }
