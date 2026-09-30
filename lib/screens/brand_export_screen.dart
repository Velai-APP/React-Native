import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'logo_generation_screen.dart';

class BrandExportScreen extends StatefulWidget {
  final String? projectId;

  final String businessName;
  final String industry;
  final String tagline;
  final String brandSummary;

  final List<String> personalities;
  final List<String> brandValues;

  final String brandVoice;
  final String logoStyle;
  final String logoType;

  final LogoConcept selectedLogo;

  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String backgroundColor;

  final String headingFont;
  final String bodyFont;

  final Map<String, dynamic> brandStrategy;

  const BrandExportScreen({
    super.key,
    required this.projectId,
    required this.businessName,
    required this.industry,
    required this.tagline,
    required this.brandSummary,
    required this.personalities,
    required this.brandValues,
    required this.brandVoice,
    required this.logoStyle,
    required this.logoType,
    required this.selectedLogo,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.headingFont,
    required this.bodyFont,
    required this.brandStrategy,
  });

  @override
  State<BrandExportScreen> createState() =>
      _BrandExportScreenState();
}

class _BrandExportScreenState extends State<BrandExportScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF059669);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  bool _isExporting = false;
  String _exportStatus = '';
  double _exportProgress = 0;

  final Set<BrandExportAsset> _selectedAssets = {
    BrandExportAsset.primaryLogo,
    BrandExportAsset.transparentLogo,
    BrandExportAsset.brandGuidelines,
    BrandExportAsset.brandData,
  };

  final List<ExportOption> _exportOptions = const [
    ExportOption(
      asset: BrandExportAsset.primaryLogo,
      title: 'Primary Logo',
      description: 'Original generated logo in PNG format',
      fileType: 'PNG',
      icon: Icons.image_outlined,
    ),
    ExportOption(
      asset: BrandExportAsset.transparentLogo,
      title: 'Transparent Logo',
      description: 'PNG preserving transparency available in the source',
      fileType: 'PNG',
      icon: Icons.layers_outlined,
    ),
    ExportOption(
      asset: BrandExportAsset.brandGuidelines,
      title: 'Brand Guidelines',
      description: 'Logo, colour, typography and usage guide',
      fileType: 'PDF',
      icon: Icons.menu_book_outlined,
    ),
    ExportOption(
      asset: BrandExportAsset.brandData,
      title: 'Brand Data',
      description: 'Structured identity details for future use',
      fileType: 'JSON',
      icon: Icons.data_object_rounded,
    ),
    ExportOption(
      asset: BrandExportAsset.colorPalette,
      title: 'Colour Palette',
      description: 'Brand colours with HEX and RGB values',
      fileType: 'JSON',
      icon: Icons.palette_outlined,
    ),
    ExportOption(
      asset: BrandExportAsset.readme,
      title: 'Usage Notes',
      description: 'Plain-text instructions for using the brand',
      fileType: 'TXT',
      icon: Icons.description_outlined,
    ),
  ];

  Future<void> _downloadIndividualAsset(
    BrandExportAsset asset,
  ) async {
    if (_isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
      _exportProgress = 0.2;
      _exportStatus = 'Preparing download...';
    });

    try {
      switch (asset) {
        case BrandExportAsset.primaryLogo:
          await _downloadLogo(
            fileSuffix: 'primary-logo',
          );
          break;

        case BrandExportAsset.transparentLogo:
          await _downloadLogo(
            fileSuffix: 'transparent-logo',
          );
          break;

        case BrandExportAsset.brandGuidelines:
          final Uint8List pdfBytes =
              await _generateBrandGuidelinesPdf();

          await _saveFile(
            name:
                '${_safeName(widget.businessName)}-brand-guidelines',
            bytes: pdfBytes,
            extension: 'pdf',
            mimeType: MimeType.pdf,
          );
          break;

        case BrandExportAsset.brandData:
          final Uint8List jsonBytes = Uint8List.fromList(
            utf8.encode(
              const JsonEncoder.withIndent('  ').convert(
                _buildBrandData(),
              ),
            ),
          );

          await _saveFile(
            name:
                '${_safeName(widget.businessName)}-brand-data',
            bytes: jsonBytes,
            extension: 'json',
            mimeType: MimeType.json,
          );
          break;

        case BrandExportAsset.colorPalette:
          final Uint8List colorBytes = Uint8List.fromList(
            utf8.encode(
              const JsonEncoder.withIndent(' ').convert(
                _buildColourData(),
              ),
            ),
          );

          await _saveFile(
            name:
                '${_safeName(widget.businessName)}-colour-palette',
            bytes: colorBytes,
            extension: 'json',
            mimeType: MimeType.json,
          );
          break;

        case BrandExportAsset.readme:
          final Uint8List readmeBytes = Uint8List.fromList(
            utf8.encode(_buildReadme()),
          );

          await _saveFile(
            name:
                '${_safeName(widget.businessName)}-usage-notes',
            bytes: readmeBytes,
            extension: 'txt',
            mimeType: MimeType.text,
          );
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _exportProgress = 1;
        _exportStatus = 'Download completed';
      });

      _showMessage('File exported successfully.');
    } catch (error) {
      _showMessage(
        _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        await Future<void>.delayed(
          const Duration(milliseconds: 500),
        );

        setState(() {
          _isExporting = false;
          _exportProgress = 0;
          _exportStatus = '';
        });
      }
    }
  }

  Future<void> _exportSelectedAsZip() async {
    if (_isExporting) {
      return;
    }

    if (_selectedAssets.isEmpty) {
      _showMessage(
        'Select at least one asset to export.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isExporting = true;
      _exportProgress = 0.05;
      _exportStatus = 'Preparing brand assets...';
    });

    try {
      final Archive archive = Archive();
      final String folderName =
          _safeName(widget.businessName);

      Uint8List? logoBytes;

      if (_selectedAssets.contains(
            BrandExportAsset.primaryLogo,
          ) ||
          _selectedAssets.contains(
            BrandExportAsset.transparentLogo,
          ) ||
          _selectedAssets.contains(
            BrandExportAsset.brandGuidelines,
          )) {
        logoBytes = await _fetchLogoBytes();

        if (!mounted) {
          return;
        }

        setState(() {
          _exportProgress = 0.25;
          _exportStatus = 'Logo downloaded';
        });
      }

      if (_selectedAssets.contains(
        BrandExportAsset.primaryLogo,
      )) {
        archive.addFile(
          ArchiveFile(
            '$folderName/logos/'
            '${folderName}_primary_logo.png',
            logoBytes!.length,
            logoBytes,
          ),
        );
      }

      if (_selectedAssets.contains(
        BrandExportAsset.transparentLogo,
      )) {
        archive.addFile(
          ArchiveFile(
            '$folderName/logos/'
            '${folderName}_transparent_logo.png',
            logoBytes!.length,
            logoBytes,
          ),
        );
      }

      if (_selectedAssets.contains(
        BrandExportAsset.brandGuidelines,
      )) {
        final Uint8List pdfBytes =
            await _generateBrandGuidelinesPdf(
          existingLogoBytes: logoBytes,
        );

        archive.addFile(
          ArchiveFile(
            '$folderName/guidelines/'
            '${folderName}_brand_guidelines.pdf',
            pdfBytes.length,
            pdfBytes,
          ),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _exportProgress = 0.55;
          _exportStatus = 'Brand guidelines created';
        });
      }

      if (_selectedAssets.contains(
        BrandExportAsset.brandData,
      )) {
        final List<int> jsonBytes = utf8.encode(
          const JsonEncoder.withIndent(' ').convert(
            _buildBrandData(),
          ),
        );

        archive.addFile(
          ArchiveFile(
            '$folderName/data/'
            '${folderName}_brand_data.json',
            jsonBytes.length,
            jsonBytes,
          ),
        );
      }

      if (_selectedAssets.contains(
        BrandExportAsset.colorPalette,
      )) {
        final List<int> colorBytes = utf8.encode(
          const JsonEncoder.withIndent(' ').convert(
            _buildColourData(),
          ),
        );

        archive.addFile(
          ArchiveFile(
            '$folderName/data/'
            '${folderName}_colour_palette.json',
            colorBytes.length,
            colorBytes,
          ),
        );
      }

      if (_selectedAssets.contains(
        BrandExportAsset.readme,
      )) {
        final List<int> readmeBytes =
            utf8.encode(_buildReadme());

        archive.addFile(
          ArchiveFile(
            '$folderName/README.txt',
            readmeBytes.length,
            readmeBytes,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _exportProgress = 0.75;
        _exportStatus = 'Packaging ZIP file...';
      });

      final List<int>? encodedArchive =
          ZipEncoder().encode(archive);

      if (encodedArchive == null ||
          encodedArchive.isEmpty) {
        throw Exception(
          'Unable to package the brand kit.',
        );
      }

      final Uint8List zipBytes =
          Uint8List.fromList(encodedArchive);

      await _saveFile(
        name:
            '${_safeName(widget.businessName)}-complete-brand-kit',
        bytes: zipBytes,
        extension: 'zip',
        mimeType: MimeType.zip,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _exportProgress = 1;
        _exportStatus = 'Brand kit exported';
      });

      _showMessage(
        'Complete brand kit exported successfully.',
      );
    } catch (error) {
      _showMessage(
        _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        await Future<void>.delayed(
          const Duration(milliseconds: 600),
        );

        setState(() {
          _isExporting = false;
          _exportProgress = 0;
          _exportStatus = '';
        });
      }
    }
  }

  Future<void> _downloadLogo({
    required String fileSuffix,
  }) async {
    setState(() {
      _exportProgress = 0.4;
      _exportStatus = 'Downloading logo...';
    });

    final Uint8List logoBytes =
        await _fetchLogoBytes();

    setState(() {
      _exportProgress = 0.8;
      _exportStatus = 'Saving logo...';
    });

    await _saveFile(
      name:
          '${_safeName(widget.businessName)}-$fileSuffix',
      bytes: logoBytes,
      extension: 'png',
      mimeType: MimeType.png,
    );
  }

  Future<Uint8List> _fetchLogoBytes() async {
    final Uri? logoUri =
        Uri.tryParse(widget.selectedLogo.imageUrl);

    if (logoUri == null) {
      throw Exception(
        'The generated logo URL is invalid.',
      );
    }

    final http.Response response =
        await http.get(logoUri);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Unable to download the generated logo.',
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception(
        'The downloaded logo file is empty.',
      );
    }

    return response.bodyBytes;
  }

  Future<void> _saveFile({
    required String name,
    required Uint8List bytes,
    required String extension,
    required MimeType mimeType,
  }) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      fileExtension: extension,
      mimeType: mimeType,
    );
  }

  Future<Uint8List> _generateBrandGuidelinesPdf({
    Uint8List? existingLogoBytes,
  }) async {
    final Uint8List logoBytes =
        existingLogoBytes ?? await _fetchLogoBytes();

    final pw.Document document = pw.Document(
      title:
          '${widget.businessName} Brand Guidelines',
      author: 'Velai Brand Kit Generator',
      creator: 'Velai',
      subject: 'Brand identity guidelines',
    );

    final pw.MemoryImage logoImage =
        pw.MemoryImage(logoBytes);

    final PdfColor primary =
        _pdfColor(widget.primaryColor);

    final PdfColor secondary =
        _pdfColor(widget.secondaryColor);

    final PdfColor accent =
        _pdfColor(widget.accentColor);

    final PdfColor brandBackground =
        _pdfColor(widget.backgroundColor);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(42),
          theme: pw.ThemeData.withFont(),
        ),
        header: (context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }

          return pw.Container(
            padding: const pw.EdgeInsets.only(
              bottom: 12,
            ),
            margin: const pw.EdgeInsets.only(
              bottom: 20,
            ),
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
                  widget.businessName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: primary,
                  ),
                ),
                pw.Text(
                  'Brand Guidelines',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(
              top: 20,
            ),
            child: pw.Row(
              mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated by Velai',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} '
                  'of ${context.pagesCount}',
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
            _pdfCoverPage(
              logoImage: logoImage,
              primary: primary,
              secondary: secondary,
            ),
            pw.NewPage(),
            _pdfSectionTitle(
              number: '01',
              title: 'Brand Overview',
              color: primary,
            ),
            pw.SizedBox(height: 18),
            _pdfInformationBlock(
              title: 'Brand Summary',
              content: widget.brandSummary,
            ),
            pw.SizedBox(height: 13),
            _pdfInformationBlock(
              title: 'Tagline',
              content: widget.tagline,
            ),
            pw.SizedBox(height: 13),
            _pdfInformationBlock(
              title: 'Industry',
              content: widget.industry,
            ),
            pw.SizedBox(height: 13),
            _pdfInformationBlock(
              title: 'Brand Personality',
              content: widget.personalities.join(', '),
            ),
            pw.SizedBox(height: 13),
            _pdfInformationBlock(
              title: 'Core Values',
              content: widget.brandValues.join(', '),
            ),
            pw.SizedBox(height: 13),
            _pdfInformationBlock(
              title: 'Tone of Voice',
              content: widget.brandVoice,
            ),
            pw.NewPage(),
            _pdfSectionTitle(
              number: '02',
              title: 'Logo System',
              color: primary,
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              height: 260,
              padding: const pw.EdgeInsets.all(30),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius:
                    pw.BorderRadius.circular(12),
                border: pw.Border.all(
                  color: PdfColors.grey300,
                ),
              ),
              child: pw.Center(
                child: pw.Image(
                  logoImage,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              widget.selectedLogo.conceptName,
              style: pw.TextStyle(
                fontSize: 17,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 7),
            pw.Text(
              widget.selectedLogo.description.isEmpty
                  ? '${widget.logoStyle} '
                      '${widget.logoType} selected for '
                      '${widget.businessName}.'
                  : widget.selectedLogo.description,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                lineSpacing: 3,
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _pdfLogoBackgroundCard(
                    title: 'Light Background',
                    logoImage: logoImage,
                    background: PdfColors.white,
                    border: PdfColors.grey300,
                  ),
                ),
                pw.SizedBox(width: 14),
                pw.Expanded(
                  child: _pdfLogoBackgroundCard(
                    title: 'Dark Background',
                    logoImage: logoImage,
                    background: PdfColors.grey900,
                  ),
                ),
              ],
            ),
            pw.NewPage(),
            _pdfSectionTitle(
              number: '03',
              title: 'Colour System',
              color: primary,
            ),
            pw.SizedBox(height: 18),
            _pdfColourCard(
              title: 'Primary',
              hex: widget.primaryColor,
              color: primary,
            ),
            pw.SizedBox(height: 13),
            _pdfColourCard(
              title: 'Secondary',
              hex: widget.secondaryColor,
              color: secondary,
            ),
            pw.SizedBox(height: 13),
            _pdfColourCard(
              title: 'Accent',
              hex: widget.accentColor,
              color: accent,
            ),
            pw.SizedBox(height: 13),
            _pdfColourCard(
              title: 'Background',
              hex: widget.backgroundColor,
              color: brandBackground,
            ),
            pw.NewPage(),
            _pdfSectionTitle(
              number: '04',
              title: 'Typography',
              color: primary,
            ),
            pw.SizedBox(height: 18),
            _pdfTypographyCard(
              label: 'Heading Font',
              fontName: widget.headingFont,
              sample: widget.businessName,
              size: 28,
            ),
            pw.SizedBox(height: 16),
            _pdfTypographyCard(
              label: 'Body Font',
              fontName: widget.bodyFont,
              sample:
                  'Clear and consistent typography supports '
                  'recognition across all communication.',
              size: 13,
            ),
            pw.NewPage(),
            _pdfSectionTitle(
              number: '05',
              title: 'Logo Usage',
              color: primary,
            ),
            pw.SizedBox(height: 18),
            _pdfGuideline(
              title: 'Maintain Clear Space',
              content:
                  'Leave enough empty space around all sides '
                  'of the logo.',
              positive: true,
            ),
            _pdfGuideline(
              title: 'Use Approved Colours',
              content:
                  'Use only approved brand colours and '
                  'background applications.',
              positive: true,
            ),
            _pdfGuideline(
              title: 'Maintain Proportions',
              content:
                  'Resize the logo proportionately without '
                  'stretching or compressing it.',
              positive: true,
            ),
            _pdfGuideline(
              title: 'Do Not Distort',
              content:
                  'Do not rotate, stretch, skew or reshape '
                  'the logo.',
              positive: false,
            ),
            _pdfGuideline(
              title: 'Do Not Add Effects',
              content:
                  'Avoid unapproved shadows, outlines, '
                  'gradients or visual effects.',
              positive: false,
            ),
            _pdfGuideline(
              title: 'Maintain Contrast',
              content:
                  'Do not place the logo on backgrounds '
                  'that reduce visibility.',
              positive: false,
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  pw.Widget _pdfCoverPage({
    required pw.MemoryImage logoImage,
    required PdfColor primary,
    required PdfColor secondary,
  }) {
    return pw.Container(
      height: 720,
      padding: const pw.EdgeInsets.all(44),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            primary,
            secondary,
          ],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius:
                  pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'BRAND GUIDELINES',
              style: pw.TextStyle(
                color: primary,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          pw.Spacer(),
          pw.Container(
            height: 280,
            width: double.infinity,
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius:
                  pw.BorderRadius.circular(18),
            ),
            child: pw.Image(
              logoImage,
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 34),
          pw.Text(
            widget.businessName,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 34,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            widget.tagline,
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 17,
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            widget.brandSummary,
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 11,
              lineSpacing: 4,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            '${widget.industry} • ${widget.logoStyle} '
            '• ${widget.logoType}',
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSectionTitle({
    required String number,
    required String title,
    required PdfColor color,
  }) {
    return pw.Row(
      children: [
        pw.Container(
          width: 44,
          height: 44,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            number,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 25,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfInformationBlock({
    required String title,
    required String content,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            content,
            style: const pw.TextStyle(
              fontSize: 11,
              lineSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfLogoBackgroundCard({
    required String title,
    required pw.MemoryImage logoImage,
    required PdfColor background,
    PdfColor? border,
  }) {
    return pw.Container(
      height: 190,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: pw.BorderRadius.circular(12),
        border: border == null
            ? null
            : pw.Border.all(color: border),
      ),
      child: pw.Column(
        children: [
          pw.Expanded(
            child: pw.Image(
              logoImage,
              fit: pw.BoxFit.contain,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: background == PdfColors.white
                  ? PdfColors.grey900
                  : PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfColourCard({
    required String title,
    required String hex,
    required PdfColor color,
  }) {
    final Color flutterColor =
        _hexToColor(hex);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 75,
            height: 75,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius:
                  pw.BorderRadius.circular(12),
            ),
          ),
          pw.SizedBox(width: 18),
          pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 7),
              pw.Text(
                'HEX  $hex',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'RGB  ${flutterColor.red}, '
                '${flutterColor.green}, '
                '${flutterColor.blue}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTypographyCard({
    required String label,
    required String fontName,
    required String sample,
    required double size,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(11),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                label.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                fontName,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            sample,
            style: pw.TextStyle(
              fontSize: size,
              fontWeight: label.contains('Heading')
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGuideline({
    required String title,
    required String content,
    required bool positive,
  }) {
    final PdfColor colour = positive
        ? PdfColors.green700
        : PdfColors.red700;

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(
        bottom: 12,
      ),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: positive
            ? PdfColors.green50
            : PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(
          color: positive
              ? PdfColors.green200
              : PdfColors.red200,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            positive ? '✓' : '✕',
            style: pw.TextStyle(
              color: colour,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: colour,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  content,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    lineSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildBrandData() {
    return {
      'projectId': widget.projectId,
      'businessName': widget.businessName,
      'industry': widget.industry,
      'tagline': widget.tagline,
      'brandSummary': widget.brandSummary,
      'personalities': widget.personalities,
      'brandValues': widget.brandValues,
      'brandVoice': widget.brandVoice,
      'logo': {
        'id': widget.selectedLogo.id,
        'conceptName':
            widget.selectedLogo.conceptName,
        'description':
            widget.selectedLogo.description,
        'imageUrl':
            widget.selectedLogo.imageUrl,
        'style': widget.logoStyle,
        'type': widget.logoType,
      },
      'colours': _buildColourData(),
      'typography': {
        'headingFont': widget.headingFont,
        'bodyFont': widget.bodyFont,
      },
      'brandStrategy': widget.brandStrategy,
      'generatedAt':
          DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _buildColourData() {
    return {
      'primary': _colourInformation(
        widget.primaryColor,
      ),
      'secondary': _colourInformation(
        widget.secondaryColor,
      ),
      'accent': _colourInformation(
        widget.accentColor,
      ),
      'background': _colourInformation(
        widget.backgroundColor,
      ),
    };
  }

  Map<String, dynamic> _colourInformation(
    String hex,
  ) {
    final Color color = _hexToColor(hex);

    return {
      'hex': hex,
      'rgb': {
        'red': color.red,
        'green': color.green,
        'blue': color.blue,
      },
    };
  }

  String _buildReadme() {
    return '''
${widget.businessName.toUpperCase()}
BRAND KIT USAGE NOTES

TAGLINE
${widget.tagline}

BRAND SUMMARY
${widget.brandSummary}

BRAND PERSONALITY
${widget.personalities.join(', ')}

CORE VALUES
${widget.brandValues.join(', ')}

TONE OF VOICE
${widget.brandVoice}

LOGO
Concept: ${widget.selectedLogo.conceptName}
Style: ${widget.logoStyle}
Type: ${widget.logoType}

COLOUR PALETTE
Primary: ${widget.primaryColor}
Secondary: ${widget.secondaryColor}
Accent: ${widget.accentColor}
Background: ${widget.backgroundColor}

TYPOGRAPHY
Heading: ${widget.headingFont}
Body: ${widget.bodyFont}

LOGO USAGE
1. Maintain clear space around the logo.
2. Keep the original logo proportions.
3. Use only approved brand colours.
4. Ensure adequate contrast against backgrounds.
5. Do not stretch, rotate or distort the logo.
6. Do not add unapproved shadows or effects.

Generated by Velai Logo & Brand Kit Generator
''';
  }

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.sizeOf(context).width;

    final bool isDesktop = width >= 950;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Export Brand Kit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 18,
            22,
            isDesktop ? 40 : 18,
            125,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1150,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildBrandPreview(isDesktop),
                  const SizedBox(height: 24),
                  _buildExportOptions(isDesktop),
                  const SizedBox(height: 24),
                  _buildPackageSummary(),
                  if (_isExporting) ...[
                    const SizedBox(height: 22),
                    _buildExportProgress(),
                  ],
                  const SizedBox(height: 24),
                  _buildImportantNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Download your brand assets',
          style: TextStyle(
            color: textColor,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Choose the files you need for '
          '${widget.businessName}, or export everything '
          'as one organised ZIP package.',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandPreview(
    bool isDesktop,
  ) {
    final Color primary =
        _hexToColor(widget.primaryColor);

    final Color secondary =
        _hexToColor(widget.secondaryColor);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop ? 30 : 21,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: _brandInformation(),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _brandLogoCard(),
                ),
              ],
            )
          : Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _brandInformation(),
                const SizedBox(height: 22),
                _brandLogoCard(),
              ],
            ),
    );
  }

  Widget _brandInformation() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(25),
          ),
          child: const Text(
            'READY TO EXPORT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              letterSpacing: 0.9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Text(
          widget.businessName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.tagline,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          widget.brandSummary,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _previewTag(widget.logoStyle),
            _previewTag(widget.logoType),
            _previewTag(widget.industry),
          ],
        ),
      ],
    );
  }

  Widget _previewTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _brandLogoCard() {
    return Container(
      height: 275,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Image.network(
        widget.selectedLogo.imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (
          context,
          child,
          progress,
        ) {
          if (progress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 58,
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportOptions(
    bool isDesktop,
  ) {
    return _sectionCard(
      title: 'Select Brand Assets',
      subtitle:
          'Select the files to include in your complete download.',
      trailing: TextButton.icon(
        onPressed: _isExporting
            ? null
            : _toggleSelectAll,
        icon: Icon(
          _selectedAssets.length ==
                  _exportOptions.length
              ? Icons.deselect_rounded
              : Icons.select_all_rounded,
        ),
        label: Text(
          _selectedAssets.length ==
                  _exportOptions.length
              ? 'Clear all'
              : 'Select all',
        ),
      ),
      child: GridView.builder(
        itemCount: _exportOptions.length,
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          mainAxisExtent: 178,
        ),
        itemBuilder: (context, index) {
          return _buildExportCard(
            _exportOptions[index],
          );
        },
      ),
    );
  }

  Widget _buildExportCard(
    ExportOption option,
  ) {
    final bool selected =
        _selectedAssets.contains(option.asset);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isExporting
            ? null
            : () {
                setState(() {
                  if (selected) {
                    _selectedAssets.remove(
                      option.asset,
                    );
                  } else {
                    _selectedAssets.add(
                      option.asset,
                    );
                  }
                });
              },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? brightBlue.withOpacity(0.07)
                : const Color(0xFFF8FAFC),
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? brightBlue
                  : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: brightBlue.withOpacity(
                        0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: Icon(
                      option.icon,
                      color: brightBlue,
                      size: 23,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Text(
                      option.fileType,
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons
                            .radio_button_unchecked,
                    color: selected
                        ? successGreen
                        : Colors.grey,
                    size: 21,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                option.title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                option.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 35,
                child: OutlinedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () {
                          _downloadIndividualAsset(
                            option.asset,
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(
                      color: borderColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                  ),
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 17,
                  ),
                  label: const Text(
                    'Download',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageSummary() {
    return _sectionCard(
      title: 'Export Package',
      subtitle:
          'Your selected files will be organised into one ZIP folder.',
      child: Column(
        children: [
          _summaryRow(
            icon: Icons.inventory_2_outlined,
            label: 'Selected assets',
            value:
                '${_selectedAssets.length} files',
          ),
          const Divider(height: 25),
          _summaryRow(
            icon: Icons.folder_zip_outlined,
            label: 'Package format',
            value: 'ZIP',
          ),
          const Divider(height: 25),
          _summaryRow(
            icon: Icons.folder_outlined,
            label: 'Folder name',
            value:
                _safeName(widget.businessName),
          ),
          const Divider(height: 25),
          _summaryRow(
            icon: Icons.check_circle_outline,
            label: 'Project status',
            value: 'Brand kit complete',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: brightBlue.withOpacity(0.09),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: brightBlue,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  _exportStatus,
                  style: const TextStyle(
                    color: Color(0xFF1E40AF),
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${(_exportProgress * 100).round()}%',
                style: const TextStyle(
                  color: brightBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _exportProgress,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFDCE7FA),
              color: brightBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'The transparent export preserves transparency only when '
              'the generated source image already contains an alpha '
              'channel. A white background embedded inside the image '
              'cannot be safely removed by this export screen.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          13,
          18,
          14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: borderColor,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(
                      color: primaryBlue,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                      _isExporting ||
                              _selectedAssets.isEmpty
                          ? null
                          : _exportSelectedAsZip,
                  style: FilledButton.styleFrom(
                    backgroundColor: brightBlue,
                    disabledBackgroundColor:
                        Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.folder_zip_outlined,
                        ),
                  label: Text(
                    _isExporting
                        ? 'Preparing Export'
                        : 'Download Complete Kit',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedAssets.length ==
          _exportOptions.length) {
        _selectedAssets.clear();
      } else {
        _selectedAssets
          ..clear()
          ..addAll(
            _exportOptions.map(
              (option) => option.asset,
            ),
          );
      }
    });
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red : successGreen,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  String _safeName(String value) {
    final String cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9]+'),
          '-',
        )
        .replaceAll(
          RegExp(r'^-+|-+$'),
          '',
        );

    return cleaned.isEmpty
        ? 'brand-kit'
        : cleaned;
  }

  Color _hexToColor(String value) {
    try {
      String cleaned =
          value.replaceAll('#', '').trim();

      if (cleaned.length == 6) {
        cleaned = 'FF$cleaned';
      }

      if (cleaned.length != 8) {
        return primaryBlue;
      }

      return Color(
        int.parse(
          cleaned,
          radix: 16,
        ),
      );
    } catch (_) {
      return primaryBlue;
    }
  }

  PdfColor _pdfColor(String value) {
    final Color color = _hexToColor(value);

    return PdfColor.fromInt(color.value);
  }
}

enum BrandExportAsset {
  primaryLogo,
  transparentLogo,
  brandGuidelines,
  brandData,
  colorPalette,
  readme,
}

class ExportOption {
  final BrandExportAsset asset;
  final String title;
  final String description;
  final String fileType;
  final IconData icon;

  const ExportOption({
    required this.asset,
    required this.title,
    required this.description,
    required this.fileType,
    required this.icon,
  });
}