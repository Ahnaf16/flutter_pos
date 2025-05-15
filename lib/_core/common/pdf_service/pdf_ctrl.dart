import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/_core/extensions/context_extension.dart';
import 'package:pos/_core/layout/space.dart';
import 'package:pos/_widgets/base_body.dart';
import 'package:pos/_widgets/loader.dart';
import 'package:printing/printing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PDFCtrl {
  Future<pw.ThemeData> theme() async {
    // final font = await PdfGoogleFonts.nunitoMedium();

    return pw.ThemeData(
      // paragraphStyle: pw.TextStyle(fontSize: 8, font: font),
      // defaultTextStyle: pw.TextStyle(fontSize: 10, font: font),
      // header5: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: font),
      // header4: pw.TextStyle(fontSize: 12, font: font),
    );
  }

  Future<pw.Document> getDoc(List<pw.Widget> widgets) async {
    final pdf = pw.Document(theme: await theme());
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        pageFormat: PdfPageFormat.a4,
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

  Future<void> open(BuildContext context, pw.Document pdf, String name) async {
    final byte = await pdf.save();
    if (!context.mounted) return;
    await showShadDialog(
      context: context,
      builder: (context) {
        return BaseBody(
          body: PdfPreview(
            build: (format) => byte,
            canDebug: false,
            canChangeOrientation: false,
            loadingWidget: const Loading(),
            padding: Pads.med(),
            pdfFileName: name,
            shouldRepaint: true,
            previewPageMargin: Pads.lg(),
            canChangePageFormat: false,
            actionBarTheme: PdfActionBarTheme(
              alignment: WrapAlignment.start,
              backgroundColor: context.colors.background,
              actionSpacing: Insets.med,
              elevation: 0,
            ),
          ),
        );
      },
    );
  }

  FileSaver get saver => FileSaver.instance;
}
