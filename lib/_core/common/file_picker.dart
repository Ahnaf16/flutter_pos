import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pos/main.export.dart';

extension FileEx on PlatformFile {
  File get file => File(xFile.path);
  bool get isImage => extension == 'jpg' || extension == 'png' || extension == 'jpeg';
}

extension XFileEx on XFile {
  File get file => File(path);
}

class FileUtil {
  final picker = FilePicker.platform;
  final imgPicker = ImagePicker();

  FutureReport<XFile> openCamera() async {
    final photo = await imgPicker.pickImage(source: ImageSource.camera);
    if (photo == null) return failure('No img selected');
    return right(photo);
  }

  FutureReport<List<XFile>> openGallery({bool multi = true}) async {
    if (multi) return right(await imgPicker.pickMultiImage(limit: 5));
    final photo = await imgPicker.pickImage(source: ImageSource.gallery);

    return right([if (photo != null) photo]);
  }

  FutureReport<List<PlatformFile>> pickFiles({bool multi = false, FileType? type}) async {
    final file = _selectFiles(multi, type).flatMap(_fileValidation);
    return file.run();
  }

  FutureReport<PlatformFile> pickSingleFile() async {
    final files = await pickFiles();
    return files.flatMap((e) => e.isEmpty ? failure('No img selected') : right(e.first));
  }

  FutureReport<List<PlatformFile>> pickImages({bool? multi}) async {
    return pickFiles(multi: multi ?? false, type: FileType.image);
  }

  Future<OpenResult> openFile(PlatformFile file) {
    return OpenFilex.open(file.xFile.path);
  }

  Future<OpenResult> openFileFromPath(String path) {
    return OpenFilex.open(path);
  }

  TaskEither<Failure, List<PlatformFile>> _fileValidation(List<PlatformFile> files) =>
      files.isEmpty ? TaskEither.left(const Failure('No img selected')) : TaskEither.of(files);

  TaskEither<Failure, List<PlatformFile>> _selectFiles(bool multi, FileType? type) {
    final t = type ?? FileType.any;

    return TaskEither.tryCatch(() async {
      final files = await picker.pickFiles(
        type: t,
        allowMultiple: multi,
        allowedExtensions: t == FileType.custom ? [] : null,
      );
      if (files == null) return [];

      return files.files;
    }, (e, s) => Failure(e.toString(), stackTrace: s));
  }
}
