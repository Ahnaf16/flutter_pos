import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_annotation/shared_preferences_annotation.dart';

part 'sp.g.dart';

/// Short hand for [SharedPreferences]
typedef SP = SharedPreferences;

@SharedPrefData(
  entries: [
    SharedPrefEntry<bool>(key: 'isDark'),
    SharedPrefEntry<String>(key: 'themeColors'),
    SharedPrefEntry<String>(key: 'language'),
  ],
)
// ignore: unused_element
_() {}
