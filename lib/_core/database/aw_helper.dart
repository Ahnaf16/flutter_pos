part of 'aw_service.dart';

FutureReport<T> _handler<T>({required Future<T> Function() call, String? errorMsg}) async {
  Failure? failure;
  try {
    return right(await call());
  } on SocketException catch (e, st) {
    failure = Failure(e.message, error: e, stackTrace: st);
  } on AppwriteException catch (e, st) {
    failure = Failure(e.message ?? errorMsg ?? kError('AwHandler'), error: e, stackTrace: st);
  } on Failure catch (e, st) {
    failure = e.copyWith(stackTrace: st);
  } catch (e, st) {
    failure = Failure(errorMsg ?? '$e', error: e, stackTrace: st);
  } finally {
    if (failure != null) catErr('AwHandler', failure.message, failure.stackTrace);
  }
  return left(failure);
}

extension DocumentListEx on DocumentList {
  List<T> convertDoc<T>(T Function(Document doc) fromDoc) => documents.map(fromDoc).toList();
}
