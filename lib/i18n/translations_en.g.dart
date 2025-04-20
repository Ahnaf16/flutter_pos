///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'translations.dart';

// Path: <root>
typedef TrEn = Tr; // ignore: unused_element

class Tr implements BaseTranslations<AppLocale, Tr> {
  /// Returns the current translations of the given [context].
  ///
  /// Usage:
  /// final t = Tr.of(context);
  static Tr of(BuildContext context) => InheritedLocaleData.of<AppLocale, Tr>(context).translations;

  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  Tr({
    Map<String, Node>? overrides,
    PluralResolver? cardinalResolver,
    PluralResolver? ordinalResolver,
    TranslationMetadata<AppLocale, Tr>? meta,
  }) : assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
       $meta =
           meta ??
           TranslationMetadata(
             locale: AppLocale.en,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    $meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <en>.
  @override
  final TranslationMetadata<AppLocale, Tr> $meta;

  /// Access flat map
  dynamic operator [](String key) => $meta.getTranslation(key);

  late final Tr _root = this; // ignore: unused_field

  Tr $copyWith({TranslationMetadata<AppLocale, Tr>? meta}) => Tr(meta: meta ?? this.$meta);

  // Translations
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Tr {
  dynamic _flatMapFunction(String path) {
    switch (path) {
      default:
        return null;
    }
  }
}
