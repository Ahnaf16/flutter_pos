// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$viewingWHHash() => r'4b8f7e3a91701ffbeb869c5f99e83c0c7a1355a9';

/// See also [ViewingWH].
@ProviderFor(ViewingWH)
final viewingWHProvider = NotifierProvider<ViewingWH, WareHouse?>.internal(
  ViewingWH.new,
  name: r'viewingWHProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$viewingWHHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ViewingWH = Notifier<WareHouse?>;
String _$homeCountersHash() => r'2f2a4743cade0250e5b1ad0995d2636c33def69a';

/// See also [HomeCounters].
@ProviderFor(HomeCounters)
final homeCountersProvider =
    AutoDisposeNotifierProvider<
      HomeCounters,
      Map<(String, RPath), dynamic>
    >.internal(
      HomeCounters.new,
      name: r'homeCountersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeCountersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeCounters = AutoDisposeNotifier<Map<(String, RPath), dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
