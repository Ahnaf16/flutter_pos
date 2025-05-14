part of 'aw_service.dart';

const kSplitPattern = ':~:';

FutureReport<T> _handler<T>({required Future<T> Function() call, String? errorMsg}) async {
  Failure? failure;
  try {
    return right(await call());
  } on SocketException catch (e, st) {
    failure = Failure(e.message, error: e, stackTrace: st);
  } on AppwriteException catch (e, st) {
    failure = Failure(e.message ?? errorMsg ?? kError('AwHandler'), error: e, stackTrace: st, type: e.type);
  } on Failure catch (e, st) {
    failure = e.copyWith(stackTrace: st);
  } catch (e, st) {
    failure = Failure(errorMsg ?? '$e', error: e, stackTrace: st);
  } finally {
    if (failure != null) catErr('AwHandler:: ${failure.type}', failure.message, failure.stackTrace);
  }
  return left(failure);
}

extension DocumentListEx on DocumentList {
  List<T> convertDoc<T>(T Function(Document doc) fromDoc) => documents.map(fromDoc).toList();
}

extension DocumentMapEx on Map<String, dynamic> {
  SMap parseCustomInfo(String key) {
    final data = this[key];
    final map = <String, String>{};

    if (data case final List list) {
      for (final info in list) {
        final parts = info.toString().split(kSplitPattern);
        if (parts.length == 2) {
          map[parts[0]] = parts[1];
        }
      }
    }
    return map;
  }

  List<String> toCustomList([String? key]) {
    final map = key == null ? this : this[key];
    final list = <String>[];
    if (map case final Map map) {
      for (final entry in map.entries) {
        list.add('${entry.key}$kSplitPattern${entry.value}');
      }
    }
    return list;
  }
}
