// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserHash() => r'9b0ccd014f3b819433956fdb97c421ca36d54599';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = FutureProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = FutureProviderRef<AppUser?>;
String _$authCtrlHash() => r'215feb227083a2fe65acf6ee609dca5b555b933f';

/// See also [AuthCtrl].
@ProviderFor(AuthCtrl)
final authCtrlProvider =
    AutoDisposeAsyncNotifierProvider<AuthCtrl, AppUser?>.internal(
      AuthCtrl.new,
      name: r'authCtrlProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authCtrlHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthCtrl = AutoDisposeAsyncNotifier<AppUser?>;
String _$authStateSyncHash() => r'cdf79882efd28862604decad839a71e6266ddde5';

/// See also [AuthStateSync].
@ProviderFor(AuthStateSync)
final authStateSyncProvider =
    NotifierProvider<AuthStateSync, Option<AppUser>>.internal(
      AuthStateSync.new,
      name: r'authStateSyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateSyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthStateSync = Notifier<Option<AppUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
