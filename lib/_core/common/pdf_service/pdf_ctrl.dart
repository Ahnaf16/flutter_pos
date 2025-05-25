import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFCtrl {
  Future<pw.Document> getDoc(List<pw.Widget> widgets, [PdfPageFormat? format]) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        pageFormat: format ?? PdfPageFormat.a5,
        maxPages: 100,
        build: (context) => widgets,
      ),
    );

    return pdf;
  }

  Future<String?> saveAs(pw.Document pdf, String name) async {
    final bytes = await pdf.save();

    return saver.saveAs(name: name, ext: 'pdf', mimeType: MimeType.pdf, bytes: bytes);
  }

  Future<String?> save(pw.Document pdf, String name) async {
    final bytes = await pdf.save();

    return saver.saveFile(name: name, ext: 'pdf', mimeType: MimeType.pdf, bytes: bytes);
  }

  Future<void> print(pw.Document pdf, String name) async {
    final byte = await pdf.save();
    unawaited(Printing.layoutPdf(onLayout: (_) => byte, name: name));
  }

  FileSaver get saver => FileSaver.instance;
}
