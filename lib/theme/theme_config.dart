import 'package:pos/main.export.dart';

typedef ThemeConfig = ({ThemeMode mode, ThemeData theme});

final themeProvider = NotifierProvider<ThemeNotifier, ThemeConfig>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeConfig> {
  final _sp = locate<SP>();

  void setTheme(ColorScheme colors) async {
    final name = _nameFromColorScheme(colors);
    if (name == null) return;
    await _sp.themeColors.setValue(name);
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
    final colors = _colorSchemes(mode);
    final color = colors[_sp.themeColors.value] ?? colors.values.first;
    return (mode: mode, theme: _theme(color));
  }

  Map<String, ColorScheme> _colorSchemes(ThemeMode mode) => {
    'Blue': ColorSchemes.blue(mode),
    'Gray': ColorSchemes.gray(mode),
    'Green': ColorSchemes.green(mode),
    'Neutral': ColorSchemes.neutral(mode),
    'Orange': ColorSchemes.orange(mode),
    'Red': ColorSchemes.red(mode),
    'Rose': ColorSchemes.rose(mode),
    'Slate': ColorSchemes.slate(mode),
    'Stone': ColorSchemes.stone(mode),
    'Violet': ColorSchemes.violet(mode),
    'Yellow': ColorSchemes.yellow(mode),
    'Zinc': ColorSchemes.zinc(mode),
  };

  String? _nameFromColorScheme(ColorScheme scheme) {
    final colors = _colorSchemes(state.mode);
    return colors.keys.firstWhereOrNull((key) => colors[key] == scheme);
  }

  ThemeData _theme(ColorScheme colors) => ThemeData(colorScheme: colors, radius: 10);
}
