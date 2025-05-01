import 'package:google_fonts/google_fonts.dart';
import 'package:pos/main.export.dart';

typedef ThemeConfig = ({ThemeMode mode, ShadThemeData theme});

final themeProvider = NotifierProvider<ThemeCtrl, ThemeConfig>(ThemeCtrl.new);

class ThemeCtrl extends Notifier<ThemeConfig> {
  final _sp = locate<SP>();

  void setTheme(String? name) async {
    if (name == null) return;
    await _sp.themeName.setValue(name);
    ref.invalidateSelf();
  }

  void setMode(ThemeMode? mode) async {
    await _sp.isDark.setValue(mode == ThemeMode.dark);
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
    return ShadThemeData(
      colorScheme: colors,
      brightness: brightness,
      textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
      cardTheme: ShadCardTheme(padding: Pads.sm(), rowMainAxisAlignment: MainAxisAlignment.start),
      inputTheme: ShadInputTheme(
        padding: kDefInputPadding,
      ).copyWith(decoration: ShadDecoration(border: ShadBorder.all(width: 1))),
      selectTheme: ShadSelectTheme(padding: kDefInputPadding),
      decoration: ShadDecoration(
        labelPadding: Pads.padding(bottom: 0, left: 5),
        descriptionPadding: Pads.padding(top: 0, left: 5),
        errorPadding: Pads.padding(top: 3, left: 5),
      ),
      primaryDialogTheme: const ShadDialogTheme(constraints: BoxConstraints(maxWidth: 700)),
    );
  }

  static final shadThemeColors = [
    'blue',
    'gray',
    'green',
    'orange',
    'red',
    'rose',
    'violet',
    'yellow',
    'neutral',
    'slate',
    'stone',
    'zinc',
  ];
}

final kDefInputPadding = Pads.padding(v: 10, h: 20);

extension ThemeModeEx on ThemeMode {
  Brightness get brightness => this == ThemeMode.dark ? Brightness.dark : Brightness.light;
}
