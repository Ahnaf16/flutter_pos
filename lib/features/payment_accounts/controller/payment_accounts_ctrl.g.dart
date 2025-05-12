// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_accounts_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentAccountsCtrlHash() =>
    r'2f1ba2eb0c9f6bc685dc9e5e5d197f02150a82d7';

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

abstract class _$PaymentAccountsCtrl
    extends BuildlessAutoDisposeAsyncNotifier<List<PaymentAccount>> {
  late final bool onlyActive;

  FutureOr<List<PaymentAccount>> build([
    bool onlyActive = true,
  ]);
}

/// See also [PaymentAccountsCtrl].
@ProviderFor(PaymentAccountsCtrl)
const paymentAccountsCtrlProvider = PaymentAccountsCtrlFamily();

/// See also [PaymentAccountsCtrl].
class PaymentAccountsCtrlFamily
    extends Family<AsyncValue<List<PaymentAccount>>> {
  /// See also [PaymentAccountsCtrl].
  const PaymentAccountsCtrlFamily();

  /// See also [PaymentAccountsCtrl].
  PaymentAccountsCtrlProvider call([
    bool onlyActive = true,
  ]) {
    return PaymentAccountsCtrlProvider(
      onlyActive,
    );
  }

  @override
  PaymentAccountsCtrlProvider getProviderOverride(
    covariant PaymentAccountsCtrlProvider provider,
  ) {
    return call(
      provider.onlyActive,
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
  String? get name => r'paymentAccountsCtrlProvider';
}

/// See also [PaymentAccountsCtrl].
class PaymentAccountsCtrlProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PaymentAccountsCtrl, List<PaymentAccount>> {
  /// See also [PaymentAccountsCtrl].
  PaymentAccountsCtrlProvider([
    bool onlyActive = true,
  ]) : this._internal(
          () => PaymentAccountsCtrl()..onlyActive = onlyActive,
          from: paymentAccountsCtrlProvider,
          name: r'paymentAccountsCtrlProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paymentAccountsCtrlHash,
          dependencies: PaymentAccountsCtrlFamily._dependencies,
          allTransitiveDependencies:
              PaymentAccountsCtrlFamily._allTransitiveDependencies,
          onlyActive: onlyActive,
        );

  PaymentAccountsCtrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.onlyActive,
  }) : super.internal();

  final bool onlyActive;

  @override
  FutureOr<List<PaymentAccount>> runNotifierBuild(
    covariant PaymentAccountsCtrl notifier,
  ) {
    return notifier.build(
      onlyActive,
    );
  }

  @override
  Override overrideWith(PaymentAccountsCtrl Function() create) {
    return ProviderOverride(
      origin: this,
      override: PaymentAccountsCtrlProvider._internal(
        () => create()..onlyActive = onlyActive,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        onlyActive: onlyActive,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PaymentAccountsCtrl,
      List<PaymentAccount>> createElement() {
    return _PaymentAccountsCtrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentAccountsCtrlProvider &&
        other.onlyActive == onlyActive;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, onlyActive.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaymentAccountsCtrlRef
    on AutoDisposeAsyncNotifierProviderRef<List<PaymentAccount>> {
  /// The parameter `onlyActive` of this provider.
  bool get onlyActive;
}

class _PaymentAccountsCtrlProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PaymentAccountsCtrl,
        List<PaymentAccount>> with PaymentAccountsCtrlRef {
  _PaymentAccountsCtrlProviderElement(super.provider);

  @override
  bool get onlyActive => (origin as PaymentAccountsCtrlProvider).onlyActive;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
