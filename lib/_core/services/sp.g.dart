// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sp.dart';

// **************************************************************************
// SharedPreferencesGenerator
// **************************************************************************

extension $SharedPreferencesGenX on SharedPreferences {
  Set<SharedPrefValueGen> get entries => {isDark, themeColors, language};

  SharedPrefValue<bool> get isDark {
    return SharedPrefValue<bool>(
      key: 'isDark',
      getter: getBool,
      setter: setBool,
      remover: remove,
    );
  }

  SharedPrefValue<String> get themeColors {
    return SharedPrefValue<String>(
      key: 'themeColors',
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
