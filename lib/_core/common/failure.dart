// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pos/main.export.dart';

typedef FutureEither<F, T> = Future<Either<F, T>>;

typedef Report<T> = Either<Failure, T>;
typedef FutureReport<T> = Future<Report<T>>;

Either<Failure, R> failure<R>(String msg, {Object? e, StackTrace? s}) {
  return Left(Failure(msg, error: e, stackTrace: s ?? StackTrace.current));
}

Future<T> failToErr<T>(Failure f) => f.toFuture<T>();

class Failure {
  const Failure(this.message, {this.errors = const <String, String>{}, this.error, StackTrace? stackTrace})
    : _stackTrace = stackTrace;

  /// The original error obj
  final Object? error;

  /// List of error messages in KEY-VALUE format
  final Map<String, String> errors;

  /// The main message of the error
  final String message;

  final StackTrace? _stackTrace;

  @override
  String toString() => message;

  StackTrace get stackTrace => _stackTrace ?? StackTrace.current;

  Map<String, dynamic> toMap() {
    return {'message': message, 'errors': errors, 'error': error};
  }

  String? getErr([String? key]) => key != null ? errors[key] : errors.values.firstOrNull;

  String err([String? name]) => errors.values.firstOrNull ?? error?.toString() ?? kError(name);

  String errOrMsg() => errors.values.firstOrNull ?? message;

  String get safeMsg => kReleaseMode ? 'Something Went Wrong' : message;
  String? get safeBody => kReleaseMode ? 'Please Try Again' : null;

  Failure copyWith({String? message, Map<String, String>? errors, Object? apiError, StackTrace? stackTrace}) {
    return Failure(
      message ?? this.message,
      errors: errors ?? this.errors,
      stackTrace: stackTrace ?? _stackTrace,
      error: apiError ?? error,
    );
  }

  Future<T> toFuture<T>() {
    final future = Future<T>.error(this, stackTrace);
    return future;
  }

  AsyncError<T> toAsyncError<T>() {
    final error = AsyncError<T>(this, stackTrace);
    return error;
  }

  Failure copyWithMessage(String msg) => copyWith(message: msg);

  void log(String name) {
    catErr(name, message, stackTrace);
    cat(errors, 'Failure Errors');
  }
}

extension FailureEx<T> on Report<T> {
  T getOrThrow() => fold((l) => throw l, (r) => r);
  T getOrDefault(T defaultValue) => fold((l) => defaultValue, (r) => r);
  T? getOrNull() => fold((l) => null, (r) => r);
  T getOrElse(T Function(Failure) onError) => fold(onError, (r) => r);

  Report<R> convert<R>(R Function(T r) right) => map<R>((T r) => right(r));
}

extension FutureFailureEx<T> on FutureReport<T> {
  Future<T> getOrThrow() => then((v) => v.getOrThrow());
  Future<T> getOrDefault(T defaultValue) => then((v) => v.getOrDefault(defaultValue));
  Future<T?> getOrNull() => then((v) => v.getOrNull());
  Future<T> getOrElse(T Function(Failure) onError) => then((v) => v.getOrElse(onError));

  Future<Report<R>> convert<R>(R Function(T r) right) => then((v) => v.convert(right));
}
