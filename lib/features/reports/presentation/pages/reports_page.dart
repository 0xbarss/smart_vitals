import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

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

  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();

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
                    _buildActionSection(isHC),
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 24),

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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Importing data from e-Nabız..."),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.cloud_download, size: 18),
            label: const Text("Import from e-Nabız"),
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
      ],
    );
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Vitals"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _systolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Systolic BP (mmHg)",
                prefixIcon: Icon(Icons.favorite_border),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _diastolicController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Diastolic BP (mmHg)",
                prefixIcon: Icon(Icons.favorite),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _glucoseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Blood Glucose (mg/dL)",
                prefixIcon: Icon(Icons.water_drop),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data Logged Successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generating PDF...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("Export as CSV"),
              subtitle: const Text("Best for Excel or data analysis"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Exporting CSV...")),
                );
              },
            ),
          ],
        ),
      ),
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