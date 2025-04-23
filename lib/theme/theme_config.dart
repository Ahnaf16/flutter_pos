import 'package:pos/main.export.dart';

typedef ThemeConfig = ({ThemeMode mode, ShadThemeData theme});

final themeProvider = NotifierProvider<ThemeCtrl, ThemeConfig>(ThemeCtrl.new);

class ThemeCtrl extends Notifier<ThemeConfig> {
  final _sp = locate<SP>();

  void setTheme(String name) async {
    await _sp.themeName.setValue(name);
    ref.invalidateSelf();
  }

  void toggleMode() async {
    final mode = state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _sp.isDark.setValue(mode == ThemeMode.dark);
    ref.invalidateSelf();
  }

  ThemeMode _effectiveMode(bool? isDark) => switch (isDark) {
    true => ThemeMode.dark,
    false => ThemeMode.light,
    null => ThemeMode.light,
  };

  @override
  ThemeConfig build() {
    final mode = _effectiveMode(_sp.isDark.value);
    final brightness = mode == ThemeMode.dark ? Brightness.dark : Brightness.light;

    final name = _sp.themeName.value ?? shadThemeColors.first;
    final colors = ShadColorScheme.fromName(name, brightness: brightness);

    return (mode: mode, theme: _theme(colors, brightness));
  }

  ShadThemeData _theme(ShadColorScheme colors, Brightness brightness) {
    return ShadThemeData(colorScheme: colors, brightness: brightness);
  }

  static final shadThemeColors = [
    'blue',
    'gray',
    'green',
    'neutral',
    'orange',
    'red',
    'rose',
    'slate',
    'stone',
    'violet',
    'yellow',
    'zinc',
  ];
}
