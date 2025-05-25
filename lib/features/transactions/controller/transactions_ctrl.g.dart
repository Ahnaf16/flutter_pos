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

String _$trxFilteredHash() => r'20c4ea49766fcca7ea645849d44c34b8876b66d5';

/// See also [trxFiltered].
@ProviderFor(trxFiltered)
const trxFilteredProvider = TrxFilteredFamily();

/// See also [trxFiltered].
class TrxFilteredFamily extends Family<AsyncValue<List<TransactionLog>>> {
  /// See also [trxFiltered].
  const TrxFilteredFamily();

  /// See also [trxFiltered].
  TrxFilteredProvider call(List<String> query) {
    return TrxFilteredProvider(query);
  }

  @override
  TrxFilteredProvider getProviderOverride(
    covariant TrxFilteredProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'trxFilteredProvider';
}

/// See also [trxFiltered].
class TrxFilteredProvider
    extends AutoDisposeFutureProvider<List<TransactionLog>> {
  /// See also [trxFiltered].
  TrxFilteredProvider(List<String> query)
    : this._internal(
        (ref) => trxFiltered(ref as TrxFilteredRef, query),
        from: trxFilteredProvider,
        name: r'trxFilteredProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trxFilteredHash,
        dependencies: TrxFilteredFamily._dependencies,
        allTransitiveDependencies: TrxFilteredFamily._allTransitiveDependencies,
        query: query,
      );

  TrxFilteredProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final List<String> query;

  @override
  Override overrideWith(
    FutureOr<List<TransactionLog>> Function(TrxFilteredRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrxFilteredProvider._internal(
        (ref) => create(ref as TrxFilteredRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TransactionLog>> createElement() {
    return _TrxFilteredProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrxFilteredProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TrxFilteredRef on AutoDisposeFutureProviderRef<List<TransactionLog>> {
  /// The parameter `query` of this provider.
  List<String> get query;
}

class _TrxFilteredProviderElement
    extends AutoDisposeFutureProviderElement<List<TransactionLog>>
    with TrxFilteredRef {
  _TrxFilteredProviderElement(super.provider);

  @override
  List<String> get query => (origin as TrxFilteredProvider).query;
}

String _$transactionLogCtrlHash() =>
    r'70262ff6675cb03a358826d42b17fe76e72cb657';

abstract class _$TransactionLogCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<TransactionLog>> {
  late final TransactionType? type;

  FutureOr<List<TransactionLog>> build([TransactionType? type]);
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
  TransactionLogCtrlProvider call([TransactionType? type]) {
    return TransactionLogCtrlProvider(type);
  }

  @override
  TransactionLogCtrlProvider getProviderOverride(
    covariant TransactionLogCtrlProvider provider,
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
  String? get name => r'transactionLogCtrlProvider';
}

/// See also [TransactionLogCtrl].
class TransactionLogCtrlProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          TransactionLogCtrl,
          List<TransactionLog>
        > {
  /// See also [TransactionLogCtrl].
  TransactionLogCtrlProvider([TransactionType? type])
    : this._internal(
        () => TransactionLogCtrl()..type = type,
        from: transactionLogCtrlProvider,
        name: r'transactionLogCtrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
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
    return notifier.build(type);
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
  AutoDisposeAsyncNotifierProviderElement<
    TransactionLogCtrl,
    List<TransactionLog>
  >
  createElement() {
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
    extends
        AutoDisposeAsyncNotifierProviderElement<
          TransactionLogCtrl,
          List<TransactionLog>
        >
    with TransactionLogCtrlRef {
  _TransactionLogCtrlProviderElement(super.provider);

  @override
  TransactionType? get type => (origin as TransactionLogCtrlProvider).type;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
