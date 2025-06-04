import 'package:appwrite/models.dart';
import 'package:pos/features/settings/repository/config_repo.dart';
import 'package:pos/main.export.dart';

class AwFile {
  const AwFile({required this.id, required this.name, required this.ext, required this.size, required this.createdAt});

  final String id;
  final String name;
  final String ext;
  final String size;
  final DateTime createdAt;

  factory AwFile.fromDoc(Document doc) => AwFile.fromMap(doc.data);
  factory AwFile.fromMap(Map<String, dynamic> map) {
    return AwFile(
      id: map.parseAwField(),
      name: map['name'],
      ext: map['ext'],
      size: map['size'],
      createdAt: map.containsKey('createdAt') ? DateTime.parse(map.parseAwField('createdAt')) : DateTime.now(),
    );
  }

  factory AwFile.fromFile(String id, PFile file) {
    return AwFile(
      id: id,
      name: file.name,
      ext: file.extension ?? file.name.split('.').last,
      size: file.size.readableByte(),
      createdAt: DateTime.now(),
    );
  }

  static AwFile? tryParse(dynamic value) {
    try {
      if (value case final AwFile f) return f;
      if (value case final Document doc) return AwFile.fromDoc(doc);
      if (value case final Map map) return AwFile.fromMap(map.toStringKey());
      return null;
    } catch (e) {
      return null;
    }
  }

  QMap toMap() => {'id': id, 'name': name, 'ext': ext, 'size': size, 'createdAt': createdAt};
  QMap toAwPost() => {'name': name, 'ext': ext, 'size': size};

  Future<String> download() async {
    final repo = locate<FileRepo>();
    return repo.download(this);
  }
}
