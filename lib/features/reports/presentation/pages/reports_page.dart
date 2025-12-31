import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../injection_container.dart' as di;
import '../../../health_dashboard/data/repositories/health_repository_impl.dart';
import 'report_history_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedPeriod = "1 Week";
  final List<String> _periods = ["1 Day", "1 Week", "1 Month", "3 Months"];

  final List<FlSpot> _heartRateData = const [
    FlSpot(0, 72),
    FlSpot(1, 75),
    FlSpot(2, 71),
    FlSpot(3, 78),
    FlSpot(4, 82),
    FlSpot(5, 74),
    FlSpot(6, 70),
  ];

  final TextEditingController _sodiumController = TextEditingController();
  final TextEditingController _ldlController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();

  String _sanitizeForPdf(String text) {
    return text
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C');
  }

  Future<void> _saveToFirestore(
    DateTime date,
    Map<String, dynamic> data,
    String type,
  ) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      try {
        final repo = di.sl<HealthRepository>();
        await repo.saveHealthReport(authState.user.id, date, data, type);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Saved to Cloud successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error saving: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save data.")),
      );
    }
  }

  Future<void> _importENabizData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Processing PDF... Please wait.")),
          );
        }

        final List<int> bytes = await file.readAsBytes();
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        String text = PdfTextExtractor(document).extractText();
        document.dispose();

        DateTime? extractedDate;
        RegExp datePattern = RegExp(r'Tarih[:\s]*(\d{2}\.\d{2}\.\d{4})');
        Match? dateMatch = datePattern.firstMatch(text);

        if (dateMatch != null) {
          try {
            String rawDate = dateMatch.group(1)!;
            extractedDate = DateFormat('dd.MM.yyyy').parse(rawDate);
          } catch (e) {
            debugPrint("Date parse error: $e");
          }
        }

        List<String> lines = text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        Map<String, dynamic> parsedData = {};
        Set<String> uniqueKeys = {};

        for (int i = 0; i < lines.length; i++) {
          String line = lines[i];
          if (line.contains(':') || (line.split('.').length > 2)) continue;
          double? value = double.tryParse(line.replaceAll(',', '.'));

          if (value != null && i > 0) {
            String name = lines[i - 1];
            if (double.tryParse(name.replaceAll(',', '.')) == null &&
                !name.contains('Tarih') &&
                !name.contains('Sonuç') &&
                name.length > 1) {
              String unit = "";
              String ref = "";

              if (i + 1 < lines.length) {
                String nextLine = lines[i + 1];
                if (!nextLine.startsWith(RegExp(r'[A-Z][a-z]'))) {
                  if (nextLine.contains('-') ||
                      nextLine.contains('<') ||
                      nextLine.contains('>')) {
                    ref = nextLine;
                  } else {
                    unit = nextLine;
                    if (i + 2 < lines.length) {
                      String nextNext = lines[i + 2];
                      if (nextNext.contains('-') ||
                          nextNext.contains('<') ||
                          nextNext.contains('>')) {
                        ref = nextNext;
                      }
                    }
                  }
                }
              }

              if (!uniqueKeys.contains(name)) {
                uniqueKeys.add(name);
                parsedData[name] = {
                  "result": line,
                  "unit": unit,
                  "reference": ref,
                };
              }
            }
          }
        }

        if (parsedData.isNotEmpty && mounted) {
          _showImportConfirmationDialog(parsedData, initialDate: extractedDate);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("No valid data found in PDF."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<List<List<String>>> _fetchAndFormatData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) throw Exception("User not logged in");

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(authState.user.id)
        .collection('health_reports')
        .orderBy('date', descending: true)
        .get();

    List<List<String>> rows = [];

    rows.add([
      "Date",
      "Source",
      "Test/Vital Name",
      "Result",
      "Unit",
      "Reference",
    ]);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = DateFormat(
        'yyyy-MM-dd',
      ).format((data['date'] as Timestamp).toDate());
      final type = data['type'] == 'enabiz_import' ? 'E-Nabiz' : 'Manual';
      final content = data['data'] as Map<String, dynamic>;

      content.forEach((key, value) {
        String result = "";
        String unit = "";
        String ref = "";

        if (value is Map) {
          result = value['result']?.toString() ?? "";
          unit = value['unit']?.toString() ?? "";
          ref = value['reference']?.toString() ?? "";
        } else {
          result = value.toString();
        }

        rows.add([dateStr, type, key, result, unit, ref]);
      });
    }
    return rows;
  }

  Future<void> _generateAndShareCSV() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fetching data and generating CSV...")),
        );
      }

      final dataRows = await _fetchAndFormatData();
      String csvData = const ListToCsvConverter().convert(dataRows);

      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/Health_Report.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      final shareParams = ShareParams(
        text: 'My SmartVitals Health Report',
        files: [XFile(path)],
      );
      await SharePlus.instance.share(shareParams);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateAndSharePDF() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fetching data and generating PDF...")),
        );
      }

      final dataRows = await _fetchAndFormatData();

      PdfDocument document = PdfDocument();
      PdfPage page = document.pages.add();

      page.graphics.drawString(
        'SmartVitals Health Report',
        PdfStandardFont(PdfFontFamily.helvetica, 20),
        bounds: const Rect.fromLTWH(0, 0, 500, 30),
      );

      page.graphics.drawString(
        'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: const Rect.fromLTWH(0, 30, 500, 20),
      );

      PdfGrid grid = PdfGrid();
      grid.columns.add(count: 6);

      final header = grid.headers.add(1)[0];
      header.cells[0].value = 'Date';
      header.cells[1].value = 'Source';
      header.cells[2].value = 'Test Name';
      header.cells[3].value = 'Result';
      header.cells[4].value = 'Unit';
      header.cells[5].value = 'Ref';

      header.style.backgroundBrush = PdfSolidBrush(PdfColor(139, 92, 246));
      header.style.textBrush = PdfBrushes.white;

      for (int i = 1; i < dataRows.length; i++) {
        PdfGridRow row = grid.rows.add();
        for (int j = 0; j < 6; j++) {
          row.cells[j].value = _sanitizeForPdf(dataRows[i][j]);
        }
      }

      grid.style.cellPadding = PdfPaddings(
        left: 5,
        right: 2,
        top: 2,
        bottom: 2,
      );
      grid.draw(page: page, bounds: const Rect.fromLTWH(0, 60, 0, 0));

      final List<int> bytes = await document.save();
      document.dispose();

      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/Health_Report.pdf";
      final file = File(path);
      await file.writeAsBytes(bytes);

      final shareParams = ShareParams(
        text: 'My SmartVitals Health Report',
        files: [XFile(path)],
      );
      SharePlus.instance.share(shareParams);
    } catch (e) {
      debugPrint("PDF ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImportConfirmationDialog(
    Map<String, dynamic> data, {
    DateTime? initialDate,
  }) {
    DateTime selectedDate = initialDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Import Confirmation"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Successfully parsed ${data.length} records."),
                  const SizedBox(height: 16),
                  const Text(
                    "Record Date:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveToFirestore(selectedDate, data, 'enabiz_import');
                  },
                  child: const Text("Save to Cloud"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualEntryDialog() {
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Log Vitals"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sodiumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Sodyum (mmol/L)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ldlController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Bad Cholesterol - LDL (mg/dL)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _glucoseController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Blood Glucose (mg/dL)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final data = {
                      if (_sodiumController.text.isNotEmpty)
                        'Sodyum': {'result': _sodiumController.text},
                      if (_ldlController.text.isNotEmpty)
                        'LDL': {'result': _ldlController.text},
                      if (_glucoseController.text.isNotEmpty)
                        'Glukoz': {'result': _glucoseController.text},
                    };

                    if (data.isNotEmpty) {
                      Navigator.pop(context);
                      _saveToFirestore(selectedDate, data, 'manual');
                      _sodiumController.clear();
                      _ldlController.clear();
                      _glucoseController.clear();
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Export Report",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Export as PDF"),
              subtitle: const Text(
                "Best for printing and sharing with doctors",
              ),
              onTap: () {
                Navigator.pop(context);
                _generateAndSharePDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("Export as CSV"),
              subtitle: const Text("Best for Excel or data analysis"),
              onTap: () {
                Navigator.pop(context);
                _generateAndShareCSV();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final bool isHC = settings.highContrast;

        final bgColor = isHC ? Colors.black : const Color(0xFFF9FAFB);
        final cardColor = isHC ? Colors.grey[900]! : Colors.white;
        final textColor = isHC ? Colors.yellowAccent : const Color(0xFF1F2937);
        final subTextColor = isHC ? Colors.white70 : Colors.grey[600];
        final chartColor = isHC ? Colors.yellowAccent : const Color(0xFF8B5CF6);

        return Scaffold(
          backgroundColor: bgColor,
          body: Column(
            children: [
              _buildHeader(isHC),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      "Blood & Lab Data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionSection(isHC),

                    const SizedBox(height: 32),
                    Divider(
                      color: isHC ? Colors.white24 : Colors.grey.shade300,
                      thickness: 1,
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Heart Rate Analysis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _periods
                            .map((p) => _buildPeriodTab(p, isHC))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      height: 320,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: isHC ? Border.all(color: Colors.white24) : null,
                        boxShadow: isHC
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Heart Rate Trend",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    "Avg: 74 bpm",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.show_chart, color: chartColor),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: LineChart(
                              _mainData(isHC, chartColor, textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Divider(
                      color: isHC ? Colors.white24 : Colors.grey.shade300,
                      thickness: 1,
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Daily Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          "Avg Steps",
                          "8,432",
                          "+12%",
                          Icons.directions_walk,
                          Colors.orange,
                          isHC,
                          cardColor,
                          textColor,
                        ),
                        _buildStatCard(
                          "Avg Calories",
                          "2,100",
                          "+2%",
                          Icons.local_fire_department,
                          Colors.red,
                          isHC,
                          cardColor,
                          textColor,
                        ),
                        _buildStatCard(
                          "Avg Water",
                          "1.8 L",
                          "+0%",
                          Icons.water_drop,
                          Colors.blue,
                          isHC,
                          cardColor,
                          textColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Divider(
                      color: isHC ? Colors.white24 : Colors.grey.shade300,
                      thickness: 1,
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "AI Insights",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInsightItem(
                      "Your heart rate recovery has improved by 5% this week.",
                      Icons.trending_up,
                      Colors.green,
                      isHC,
                      cardColor,
                      textColor,
                      subTextColor!,
                    ),
                    _buildInsightItem(
                      "You slept less than 6 hours on Tuesday. Try to sleep earlier.",
                      Icons.warning_amber_rounded,
                      Colors.orange,
                      isHC,
                      cardColor,
                      textColor,
                      subTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isHighContrast) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : null,
        gradient: isHighContrast
            ? null
            : const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: isHighContrast
            ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Health Report",
            style: TextStyle(
              color: isHighContrast ? Colors.yellowAccent : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track, Analyze, and Export your data",
            style: TextStyle(
              color: isHighContrast
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(bool isHC) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showManualEntryDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Log Data"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHC ? Colors.grey[800] : Colors.white,
                  foregroundColor: isHC
                      ? Colors.yellowAccent
                      : const Color(0xFF7C3AED),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isHC ? Colors.white54 : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showExportOptions,
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Export"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHC
                      ? Colors.yellowAccent
                      : const Color(0xFF7C3AED),
                  foregroundColor: isHC ? Colors.black : Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _importENabizData,
                icon: const Icon(Icons.cloud_download, size: 18),
                label: const Text("Import PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReportHistoryPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text("History"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodTab(String period, bool isHC) {
    final isSelected = _selectedPeriod == period;
    final activeColor = isHC ? Colors.yellowAccent : const Color(0xFF7C3AED);
    final inactiveBg = isHC ? Colors.grey[800] : Colors.white;
    final inactiveText = isHC ? Colors.white70 : Colors.grey[600];

    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: isHC ? Colors.white24 : Colors.grey.shade200),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected
                ? (isHC ? Colors.black : Colors.white)
                : inactiveText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String trend,
    IconData icon,
    Color color,
    bool isHC,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isHC ? Border.all(color: Colors.white24) : null,
        boxShadow: isHC
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isHC ? Colors.white : color, size: 20),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isHC ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    String text,
    IconData icon,
    Color iconColor,
    bool isHC,
    Color bgColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isHC ? Border.all(color: Colors.white24) : null,
        boxShadow: isHC
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: isHC ? Colors.yellowAccent : iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.4, color: subTextColor),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _mainData(bool isHC, Color chartColor, Color textColor) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 50,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: _heartRateData,
          isCurved: true,
          color: chartColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: chartColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
