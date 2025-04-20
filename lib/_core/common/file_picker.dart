import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pos/main.export.dart';

class FileUtil {
  final picker = FilePicker.platform;

  FutureReport<List<PlatformFile>> pickFiles({bool multi = false}) async {
    final file = _selectImage(multi).flatMap(_fileValidation);
    return file.run();
  }

  FutureReport<PlatformFile> pickSingleImage() async {
    final files = await pickFiles(multi: false);
    return files.flatMap((e) => e.isEmpty ? failure('No img selected') : right(e.first));
  }

  FutureReport<List<PlatformFile>> pickImages({bool? multi}) async {
    return pickFiles(multi: multi ?? false);
  }

  Future<OpenResult> openFile(PlatformFile file) {
    return OpenFilex.open(file.xFile.path);
  }

  TaskEither<Failure, List<PlatformFile>> _fileValidation(List<PlatformFile> files) =>
      files.isEmpty ? TaskEither.left(const Failure('No img selected')) : TaskEither.of(files);

  TaskEither<Failure, List<PlatformFile>> _selectImage(bool multi) {
    return TaskEither.tryCatch(() async {
      final files = await picker.pickFiles(type: FileType.any, allowMultiple: multi);
      if (files == null) return [];

      return files.files;
    }, (e, s) => Failure(e.toString(), stackTrace: s)..log('FilePicker'));
  }
}
