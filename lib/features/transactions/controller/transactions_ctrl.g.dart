// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionLogCtrlHash() =>
    r'd962c30db1f85437f523d622f34d9dc83fdcfa40';

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

abstract class _$TransactionLogCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<TransactionLog>> {
  late final TransactionType? type;

  FutureOr<List<TransactionLog>> build([
    TransactionType? type,
  ]);
}

/// See also [TransactionLogCtrl].
@ProviderFor(TransactionLogCtrl)
const transactionLogCtrlProvider = TransactionLogCtrlFamily();

/// See also [TransactionLogCtrl].
class TransactionLogCtrlFamily
    extends Family<AsyncValue<List<TransactionLog>>> {
  /// See also [TransactionLogCtrl].
  const TransactionLogCtrlFamily();

  /// See also [TransactionLogCtrl].
  TransactionLogCtrlProvider call([
    TransactionType? type,
  ]) {
    return TransactionLogCtrlProvider(
      type,
    );
  }

  @override
  TransactionLogCtrlProvider getProviderOverride(
    covariant TransactionLogCtrlProvider provider,
  ) {
    return call(
      provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionLogCtrlProvider';
}

/// See also [TransactionLogCtrl].
class TransactionLogCtrlProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TransactionLogCtrl, List<TransactionLog>> {
  /// See also [TransactionLogCtrl].
  TransactionLogCtrlProvider([
    TransactionType? type,
  ]) : this._internal(
          () => TransactionLogCtrl()..type = type,
          from: transactionLogCtrlProvider,
          name: r'transactionLogCtrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionLogCtrlHash,
          dependencies: TransactionLogCtrlFamily._dependencies,
          allTransitiveDependencies:
              TransactionLogCtrlFamily._allTransitiveDependencies,
          type: type,
        );

  TransactionLogCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final TransactionType? type;

  @override
  FutureOr<List<TransactionLog>> runNotifierBuild(
    covariant TransactionLogCtrl notifier,
  ) {
    return notifier.build(
      type,
    );
  }

  @override
  Override overrideWith(TransactionLogCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: TransactionLogCtrlProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<TransactionLogCtrl,
      List<TransactionLog>> createElement() {
    return _TransactionLogCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionLogCtrlProvider && other.type == type;
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
mixin TransactionLogCtrlRef
    on AutoDisposeAsyncNotifierProviderRef<List<TransactionLog>> {
  /// The parameter `type` of this provider.
  TransactionType? get type;
}

class _TransactionLogCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TransactionLogCtrl,
        List<TransactionLog>> with TransactionLogCtrlRef {
  _TransactionLogCtrlProviderElement(super.provider);

  @override
  TransactionType? get type => (origin as TransactionLogCtrlProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
