// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sp.dart';

// **************************************************************************
// SharedPreferencesGenerator
// **************************************************************************

extension $SharedPreferencesGenX on SharedPreferences {
  Set<SharedPrefValueGen> get entries => {accessToken, isDark, themeName, language};

  SharedPrefValue<String> get accessToken {
    return SharedPrefValue<String>(key: 'accessToken', getter: getString, setter: setString, remover: remove);
  }

  SharedPrefValue<bool> get isDark {
    return SharedPrefValue<bool>(key: 'isDark', getter: getBool, setter: setBool, remover: remove);
  }

  SharedPrefValue<String> get themeName {
    return SharedPrefValue<String>(key: 'themeName', getter: getString, setter: setString, remover: remove);
  }

  SharedPrefValue<String> get language {
    return SharedPrefValue<String>(key: 'language', getter: getString, setter: setString, remover: remove);
  }
}
