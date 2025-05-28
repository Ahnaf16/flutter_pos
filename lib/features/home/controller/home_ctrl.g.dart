// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$viewingWHHash() => r'09b47aee08ae6e4d1f3521f5a498f7636fef83e3';

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
String _$barDataCtrlHash() => r'1738cf1fbf84394a01072ec374f8344ef3f67de9';

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

abstract class _$BarDataCtrl
    extends BuildlessAutoDisposeNotifier<Map<int, List<TransactionLog>>> {
  late final TableType type;
  late final int month;

  Map<int, List<TransactionLog>> build(TableType type, int month);
}

/// See also [BarDataCtrl].
@ProviderFor(BarDataCtrl)
const barDataCtrlProvider = BarDataCtrlFamily();

/// See also [BarDataCtrl].
class BarDataCtrlFamily extends Family<Map<int, List<TransactionLog>>> {
  /// See also [BarDataCtrl].
  const BarDataCtrlFamily();

  /// See also [BarDataCtrl].
  BarDataCtrlProvider call(TableType type, int month) {
    return BarDataCtrlProvider(type, month);
  }

  @override
  BarDataCtrlProvider getProviderOverride(
    covariant BarDataCtrlProvider provider,
  ) {
    return call(provider.type, provider.month);
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
  BarDataCtrlProvider(TableType type, int month)
    : this._internal(
        () => BarDataCtrl()
          ..type = type
          ..month = month,
        from: barDataCtrlProvider,
        name: r'barDataCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$barDataCtrlHash,
        dependencies: BarDataCtrlFamily._dependencies,
        allTransitiveDependencies: BarDataCtrlFamily._allTransitiveDependencies,
        type: type,
        month: month,
      );

  BarDataCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
    required this.month,
  }) : super.internal();

  final TableType type;
  final int month;

  @override
  Map<int, List<TransactionLog>> runNotifierBuild(
    covariant BarDataCtrl notifier,
  ) {
    return notifier.build(type, month);
  }

  @override
  Override overrideWith(BarDataCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: BarDataCtrlProvider._internal(
        () => create()
          ..type = type
          ..month = month,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
        month: month,
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
        other.type == type &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BarDataCtrlRef
    on AutoDisposeNotifierProviderRef<Map<int, List<TransactionLog>>> {
  /// The parameter `type` of this provider.
  TableType get type;

  /// The parameter `month` of this provider.
  int get month;
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
  TableType get type => (origin as BarDataCtrlProvider).type;
  @override
  int get month => (origin as BarDataCtrlProvider).month;
}

String _$pieDataCtrlHash() => r'ae41c12137ee26574fe862f47b70057039a27f49';

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
