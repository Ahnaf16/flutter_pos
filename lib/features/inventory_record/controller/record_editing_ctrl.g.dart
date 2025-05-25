// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_editing_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordEditingCtrlHash() => r'0a43b825265e69244596cab2334c5e7c2d5ed362';

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

abstract class _$RecordEditingCtrl
    extends BuildlessAutoDisposeNotifier<InventoryRecordState> {
  late final RecordType type;

  InventoryRecordState build(RecordType type);
}

/// See also [RecordEditingCtrl].
@ProviderFor(RecordEditingCtrl)
const recordEditingCtrlProvider = RecordEditingCtrlFamily();

/// See also [RecordEditingCtrl].
class RecordEditingCtrlFamily extends Family<InventoryRecordState> {
  /// See also [RecordEditingCtrl].
  const RecordEditingCtrlFamily();

  /// See also [RecordEditingCtrl].
  RecordEditingCtrlProvider call(RecordType type) {
    return RecordEditingCtrlProvider(type);
  }

  @override
  RecordEditingCtrlProvider getProviderOverride(
    covariant RecordEditingCtrlProvider provider,
  ) {
    return call(provider.type);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recordEditingCtrlProvider';
}

/// See also [RecordEditingCtrl].
class RecordEditingCtrlProvider
    extends
        AutoDisposeNotifierProviderImpl<
          RecordEditingCtrl,
          InventoryRecordState
        > {
  /// See also [RecordEditingCtrl].
  RecordEditingCtrlProvider(RecordType type)
    : this._internal(
        () => RecordEditingCtrl()..type = type,
        from: recordEditingCtrlProvider,
        name: r'recordEditingCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recordEditingCtrlHash,
        dependencies: RecordEditingCtrlFamily._dependencies,
        allTransitiveDependencies:
            RecordEditingCtrlFamily._allTransitiveDependencies,
        type: type,
      );

  RecordEditingCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final RecordType type;

  @override
  InventoryRecordState runNotifierBuild(covariant RecordEditingCtrl notifier) {
    return notifier.build(type);
  }

  @override
  Override overrideWith(RecordEditingCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecordEditingCtrlProvider._internal(
        () => create()..type = type,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<RecordEditingCtrl, InventoryRecordState>
  createElement() {
    return _RecordEditingCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordEditingCtrlProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecordEditingCtrlRef
    on AutoDisposeNotifierProviderRef<InventoryRecordState> {
  /// The parameter `type` of this provider.
  RecordType get type;
}

class _RecordEditingCtrlProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          RecordEditingCtrl,
          InventoryRecordState
        >
    with RecordEditingCtrlRef {
  _RecordEditingCtrlProviderElement(super.provider);

  @override
  RecordType get type => (origin as RecordEditingCtrlProvider).type;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
