// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$viewingWHHash() => r'0e67e68687e3e44d943058737eeb3a6b503f81b6';

/// See also [ViewingWH].
@ProviderFor(ViewingWH)
final viewingWHProvider =
    NotifierProvider<ViewingWH, ({WareHouse? my, WareHouse? viewing})>.internal(
      ViewingWH.new,
      name: r'viewingWHProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$viewingWHHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ViewingWH = Notifier<({WareHouse? my, WareHouse? viewing})>;
String _$homeCountersHash() => r'd15de8307cbbbcfd0da3daee87b4939ecb212da5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$HomeCounters
    extends
        BuildlessAutoDisposeNotifier<Map<(String, RPath, IconData), dynamic>> {
  late final DateTime? start;
  late final DateTime? end;

  Map<(String, RPath, IconData), dynamic> build(DateTime? start, DateTime? end);
}

/// See also [HomeCounters].
@ProviderFor(HomeCounters)
const homeCountersProvider = HomeCountersFamily();

/// See also [HomeCounters].
class HomeCountersFamily
    extends Family<Map<(String, RPath, IconData), dynamic>> {
  /// See also [HomeCounters].
  const HomeCountersFamily();

  /// See also [HomeCounters].
  HomeCountersProvider call(DateTime? start, DateTime? end) {
    return HomeCountersProvider(start, end);
  }

  @override
  HomeCountersProvider getProviderOverride(
    covariant HomeCountersProvider provider,
  ) {
    return call(provider.start, provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'homeCountersProvider';
}

/// See also [HomeCounters].
class HomeCountersProvider
    extends
        AutoDisposeNotifierProviderImpl<
          HomeCounters,
          Map<(String, RPath, IconData), dynamic>
        > {
  /// See also [HomeCounters].
  HomeCountersProvider(DateTime? start, DateTime? end)
    : this._internal(
        () => HomeCounters()
          ..start = start
          ..end = end,
        from: homeCountersProvider,
        name: r'homeCountersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$homeCountersHash,
        dependencies: HomeCountersFamily._dependencies,
        allTransitiveDependencies:
            HomeCountersFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  HomeCountersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime? start;
  final DateTime? end;

  @override
  Map<(String, RPath, IconData), dynamic> runNotifierBuild(
    covariant HomeCounters notifier,
  ) {
    return notifier.build(start, end);
  }

  @override
  Override overrideWith(HomeCounters Function() create) {
    return ProviderOverride(
      origin: this,
      override: HomeCountersProvider._internal(
        () => create()
          ..start = start
          ..end = end,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    HomeCounters,
    Map<(String, RPath, IconData), dynamic>
  >
  createElement() {
    return _HomeCountersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeCountersProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HomeCountersRef
    on AutoDisposeNotifierProviderRef<Map<(String, RPath, IconData), dynamic>> {
  /// The parameter `start` of this provider.
  DateTime? get start;

  /// The parameter `end` of this provider.
  DateTime? get end;
}

class _HomeCountersProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          HomeCounters,
          Map<(String, RPath, IconData), dynamic>
        >
    with HomeCountersRef {
  _HomeCountersProviderElement(super.provider);

  @override
  DateTime? get start => (origin as HomeCountersProvider).start;
  @override
  DateTime? get end => (origin as HomeCountersProvider).end;
}

String _$barDataCtrlHash() => r'a6408f979cfb296477dd796860da8214fe45c0ae';

abstract class _$BarDataCtrl
    extends BuildlessAutoDisposeNotifier<Map<int, List<TransactionLog>>> {
  late final DateTime? start;
  late final DateTime? end;

  Map<int, List<TransactionLog>> build(DateTime? start, DateTime? end);
}

/// See also [BarDataCtrl].
@ProviderFor(BarDataCtrl)
const barDataCtrlProvider = BarDataCtrlFamily();

/// See also [BarDataCtrl].
class BarDataCtrlFamily extends Family<Map<int, List<TransactionLog>>> {
  /// See also [BarDataCtrl].
  const BarDataCtrlFamily();

  /// See also [BarDataCtrl].
  BarDataCtrlProvider call(DateTime? start, DateTime? end) {
    return BarDataCtrlProvider(start, end);
  }

  @override
  BarDataCtrlProvider getProviderOverride(
    covariant BarDataCtrlProvider provider,
  ) {
    return call(provider.start, provider.end);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'barDataCtrlProvider';
}

/// See also [BarDataCtrl].
class BarDataCtrlProvider
    extends
        AutoDisposeNotifierProviderImpl<
          BarDataCtrl,
          Map<int, List<TransactionLog>>
        > {
  /// See also [BarDataCtrl].
  BarDataCtrlProvider(DateTime? start, DateTime? end)
    : this._internal(
        () => BarDataCtrl()
          ..start = start
          ..end = end,
        from: barDataCtrlProvider,
        name: r'barDataCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$barDataCtrlHash,
        dependencies: BarDataCtrlFamily._dependencies,
        allTransitiveDependencies: BarDataCtrlFamily._allTransitiveDependencies,
        start: start,
        end: end,
      );

  BarDataCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.start,
    required this.end,
  }) : super.internal();

  final DateTime? start;
  final DateTime? end;

  @override
  Map<int, List<TransactionLog>> runNotifierBuild(
    covariant BarDataCtrl notifier,
  ) {
    return notifier.build(start, end);
  }

  @override
  Override overrideWith(BarDataCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: BarDataCtrlProvider._internal(
        () => create()
          ..start = start
          ..end = end,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    BarDataCtrl,
    Map<int, List<TransactionLog>>
  >
  createElement() {
    return _BarDataCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BarDataCtrlProvider &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BarDataCtrlRef
    on AutoDisposeNotifierProviderRef<Map<int, List<TransactionLog>>> {
  /// The parameter `start` of this provider.
  DateTime? get start;

  /// The parameter `end` of this provider.
  DateTime? get end;
}

class _BarDataCtrlProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          BarDataCtrl,
          Map<int, List<TransactionLog>>
        >
    with BarDataCtrlRef {
  _BarDataCtrlProviderElement(super.provider);

  @override
  DateTime? get start => (origin as BarDataCtrlProvider).start;
  @override
  DateTime? get end => (origin as BarDataCtrlProvider).end;
}

String _$pieDataCtrlHash() => r'b5dbb497fc116de4fa402d3bf8b4b8751f19bf4a';

/// See also [PieDataCtrl].
@ProviderFor(PieDataCtrl)
final pieDataCtrlProvider =
    AutoDisposeNotifierProvider<
      PieDataCtrl,
      Map<TransactionType, List<TransactionLog>>
    >.internal(
      PieDataCtrl.new,
      name: r'pieDataCtrlProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pieDataCtrlHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PieDataCtrl =
    AutoDisposeNotifier<Map<TransactionType, List<TransactionLog>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
