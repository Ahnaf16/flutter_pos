// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sp.dart';

// **************************************************************************
// SharedPreferencesGenerator
// **************************************************************************

extension $SharedPreferencesGenX on SharedPreferences {
  Set<SharedPrefValueGen> get entries => {isDark, themeName, language};

  SharedPrefValue<bool> get isDark {
    return SharedPrefValue<bool>(
      key: 'isDark',
      getter: getBool,
      setter: setBool,
      remover: remove,
    );
  }

  SharedPrefValue<String> get themeName {
    return SharedPrefValue<String>(
      key: 'themeName',
      getter: getString,
      setter: setString,
      remover: remove,
    );
  }

  SharedPrefValue<String> get language {
    return SharedPrefValue<String>(
      key: 'language',
      getter: getString,
      setter: setString,
      remover: remove,
    );
  }
}
