// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserHash() => r'87a475c66eb9792dda3cb451b67cb448c4e4b36a';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = FutureProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = FutureProviderRef<AppUser?>;
String _$authCtrlHash() => r'5f3c498e74e5383f15a2bfe887373674a822053a';

/// See also [AuthCtrl].
@ProviderFor(AuthCtrl)
final authCtrlProvider =
    AutoDisposeAsyncNotifierProvider<AuthCtrl, AppUser?>.internal(
  AuthCtrl.new,
  name: r'authCtrlProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authCtrlHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthCtrl = AutoDisposeAsyncNotifier<AppUser?>;
String _$authStateSyncHash() => r'20f2b07d48f1ddcf38d07946a93e4e2c5de6107c';

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
