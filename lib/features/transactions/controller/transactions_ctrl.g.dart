// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionsByPartiHash() =>
    r'bebb72fdeb4f182e86e2465fbd0fb4e51e78e5d1';

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

/// See also [transactionsByParti].
@ProviderFor(transactionsByParti)
const transactionsByPartiProvider = TransactionsByPartiFamily();

/// See also [transactionsByParti].
class TransactionsByPartiFamily
    extends Family<AsyncValue<List<TransactionLog>>> {
  /// See also [transactionsByParti].
  const TransactionsByPartiFamily();

  /// See also [transactionsByParti].
  TransactionsByPartiProvider call(String? parti) {
    return TransactionsByPartiProvider(parti);
  }

  @override
  TransactionsByPartiProvider getProviderOverride(
    covariant TransactionsByPartiProvider provider,
  ) {
    return call(provider.parti);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionsByPartiProvider';
}

/// See also [transactionsByParti].
class TransactionsByPartiProvider
    extends AutoDisposeFutureProvider<List<TransactionLog>> {
  /// See also [transactionsByParti].
  TransactionsByPartiProvider(String? parti)
    : this._internal(
        (ref) => transactionsByParti(ref as TransactionsByPartiRef, parti),
        from: transactionsByPartiProvider,
        name: r'transactionsByPartiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$transactionsByPartiHash,
        dependencies: TransactionsByPartiFamily._dependencies,
        allTransitiveDependencies:
            TransactionsByPartiFamily._allTransitiveDependencies,
        parti: parti,
      );

  TransactionsByPartiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.parti,
  }) : super.internal();

  final String? parti;

  @override
  Override overrideWith(
    FutureOr<List<TransactionLog>> Function(TransactionsByPartiRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsByPartiProvider._internal(
        (ref) => create(ref as TransactionsByPartiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        parti: parti,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionLog>> createElement() {
    return _TransactionsByPartiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsByPartiProvider && other.parti == parti;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, parti.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionsByPartiRef
    on AutoDisposeFutureProviderRef<List<TransactionLog>> {
  /// The parameter `parti` of this provider.
  String? get parti;
}

class _TransactionsByPartiProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionLog>>
    with TransactionsByPartiRef {
  _TransactionsByPartiProviderElement(super.provider);

  @override
  String? get parti => (origin as TransactionsByPartiProvider).parti;
}

String _$transactionLogCtrlHash() =>
    r'7f78c1e80409b2a6da2e5d2aecac98343d3676fc';

/// See also [TransactionLogCtrl].
@ProviderFor(TransactionLogCtrl)
final transactionLogCtrlProvider =
    AutoDisposeAsyncNotifierProvider<
      TransactionLogCtrl,
      List<TransactionLog>
    >.internal(
      TransactionLogCtrl.new,
      name: r'transactionLogCtrlProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionLogCtrlHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TransactionLogCtrl = AutoDisposeAsyncNotifier<List<TransactionLog>>;
String _$trxFilteredHash() => r'5a8d5467c78af689e49c53c65e1c44a85f593857';

/// See also [TrxFiltered].
@ProviderFor(TrxFiltered)
final trxFilteredProvider =
    AutoDisposeNotifierProvider<TrxFiltered, List<TransactionLog>>.internal(
      TrxFiltered.new,
      name: r'trxFilteredProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trxFilteredHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrxFiltered = AutoDisposeNotifier<List<TransactionLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
