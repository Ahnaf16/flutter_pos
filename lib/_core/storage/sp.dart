import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_annotation/shared_preferences_annotation.dart';

part 'sp.gen.dart';

/// Short hand for [SharedPreferences]
typedef SP = SharedPreferences;

@SharedPrefData(
  entries: [
    SharedPrefEntry<bool>(key: 'isDark'),
    SharedPrefEntry<String>(key: 'themeName'),
    SharedPrefEntry<String>(key: 'language'),
    SharedPrefEntry<String>(key: 'currencySymbol'),
    SharedPrefEntry<bool>(key: 'symbolOnLeft'),
  ],
)
// ignore: unused_element
void _() {}
