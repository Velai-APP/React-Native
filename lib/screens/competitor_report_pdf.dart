import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CompetitorReportPdf {
  static Future<void> download({
    required String companyName,
    required String industry,
    required Map<String, dynamic> analysisResult,
  }) async {
    final bytes = await _buildPdf(
      companyName: companyName,
      industry: industry,
      analysisResult: analysisResult,
    );

    final safeName = companyName
        .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');

    await Printing.sharePdf(
      bytes: bytes,
      filename:
          '${safeName}_Competitor_Intelligence_Report.pdf',
    );
  }

  static Future<Uint8List> _buildPdf({
    required String companyName,
    required String industry,
    required Map<String, dynamic> analysisResult,
  }) async {
    final pdf = pw.Document();

    final fullReport =
        analysisResult["fullReport"]?.toString() ?? "";

    final executiveSummary =
        _stringList(analysisResult["executiveSummary"]);

    final sources =
        _mapList(analysisResult["sources"]);

    final generatedAt =
        analysisResult["generatedAt"]?.toString() ?? "";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),

        header: (context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }

          return pw.Container(
            padding:
                const pw.EdgeInsets.only(bottom: 10),
            margin:
                const pw.EdgeInsets.only(bottom: 18),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey300,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  companyName,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  'COMPETITOR INTELLIGENCE',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },

        footer: (context) {
          return pw.Container(
            margin:
                const pw.EdgeInsets.only(top: 15),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AI-assisted competitive intelligence',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of '
                  '${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },

        build: (context) {
          return [
            _cover(
              companyName,
              industry,
              generatedAt,
            ),

            pw.SizedBox(height: 30),

            _sectionTitle(
              'Executive Summary',
            ),

            pw.SizedBox(height: 10),

            ...executiveSummary
                .take(10)
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => _numberedFinding(
                    entry.key + 1,
                    entry.value,
                  ),
                ),

            if (fullReport.isNotEmpty) ...[
              pw.SizedBox(height: 25),

              pw.NewPage(),

              _sectionTitle(
                'Detailed Intelligence Report',
              ),

              pw.SizedBox(height: 12),

              ..._markdownToPdf(
                fullReport,
              ),
            ],

            if (sources.isNotEmpty) ...[
              pw.SizedBox(height: 25),

              _sectionTitle(
                'Research Sources',
              ),

              pw.SizedBox(height: 10),

              ...sources.map(
                (source) {
                  final title =
                      source["title"]?.toString() ?? "";

                  final url =
                      source["url"]?.toString() ?? "";

                  return pw.Container(
                    margin:
                        const pw.EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title.isEmpty
                              ? "Source"
                              : title,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),

                        if (url.isNotEmpty)
                          pw.Text(
                            url,
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color:
                                  PdfColors.blue700,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cover(
    String company,
    String industry,
    String generatedAt,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(30),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo900,
        borderRadius:
            pw.BorderRadius.circular(18),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'COMPETITOR INTELLIGENCE',
            style: pw.TextStyle(
              color: PdfColors.indigo100,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 30),

          pw.Text(
            company,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            '$industry • AI Research Report',
            style: const pw.TextStyle(
              color: PdfColors.indigo100,
              fontSize: 13,
            ),
          ),

          if (generatedAt.isNotEmpty) ...[
            pw.SizedBox(height: 25),
            pw.Text(
              'Generated: $generatedAt',
              style: const pw.TextStyle(
                color: PdfColors.grey300,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(
    String title,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.only(bottom: 7),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.indigo400,
            width: 1.5,
          ),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.indigo900,
        ),
      ),
    );
  }

  static pw.Widget _numberedFinding(
    int number,
    String text,
  ) {
    return pw.Container(
      margin:
          const pw.EdgeInsets.only(bottom: 9),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 23,
            height: 23,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius:
                  pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              number.toString().padLeft(2, '0'),
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.indigo700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(width: 9),

          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 10.5,
                lineSpacing: 3,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _markdownToPdf(
    String markdown,
  ) {
    final widgets = <pw.Widget>[];

    final lines =
        markdown.split('\n');

    for (final rawLine in lines) {
      final line =
          rawLine.trim();

      if (line.isEmpty) {
        widgets.add(
          pw.SizedBox(height: 5),
        );
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(
          pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              top: 16,
              bottom: 8,
            ),
            child: pw.Text(
              _cleanMarkdown(
                line.substring(2),
              ),
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight:
                    pw.FontWeight.bold,
                color:
                    PdfColors.indigo900,
              ),
            ),
          ),
        );
      } else if (
          line.startsWith('## ')) {
        widgets.add(
          pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              top: 15,
              bottom: 7,
            ),
            child: pw.Text(
              _cleanMarkdown(
                line.substring(3),
              ),
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight:
                    pw.FontWeight.bold,
                color:
                    PdfColors.indigo800,
              ),
            ),
          ),
        );
      } else if (
          line.startsWith('### ')) {
        widgets.add(
          pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              top: 10,
              bottom: 5,
            ),
            child: pw.Text(
              _cleanMarkdown(
                line.substring(4),
              ),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),
        );
      } else if (
          line.startsWith('- ') ||
          line.startsWith('* ')) {
        widgets.add(
          pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              left: 8,
              bottom: 4,
            ),
            child: pw.Row(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• '),
                pw.Expanded(
                  child: pw.Text(
                    _cleanMarkdown(
                      line.substring(2),
                    ),
                    style:
                        const pw.TextStyle(
                      fontSize: 10,
                      lineSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (
          line.startsWith('|') ||
          line.startsWith('---')) {
        // Skip raw markdown table separators.
      } else {
        widgets.add(
          pw.Padding(
            padding:
                const pw.EdgeInsets.only(
              bottom: 6,
            ),
            child: pw.Text(
              _cleanMarkdown(line),
              style: const pw.TextStyle(
                fontSize: 10,
                lineSpacing: 3,
                color:
                    PdfColors.grey800,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  static String _cleanMarkdown(
    String value,
  ) {
    return value
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('`', '');
  }

  static List<String> _stringList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .map((e) => e.toString())
        .toList();
  }

  static List<Map<String, dynamic>> _mapList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (e) =>
              Map<String, dynamic>.from(e),
        )
        .toList();
  }
}