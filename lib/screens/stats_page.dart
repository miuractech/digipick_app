import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../services/auth_service.dart';

class StatsPage extends StatefulWidget {
  final Map<String, dynamic>? device;

  const StatsPage({super.key, this.device});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool isDaily = true; // Toggle between daily and monthly
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _statisticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceStatistics();
  }

  Future<void> _loadDeviceStatistics() async {
    if (widget.device == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final tests = await _authService.getAllDeviceTests(widget.device!['id']);
      setState(() {
        _statisticsData = _calculateStatistics(tests);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateStatistics(List<Map<String, dynamic>> tests) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Daily stats (last 7 days)
    final dailyStats = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      dailyStats[date] = 0;
    }
    
    // Monthly stats (last 12 months)
    final monthlyStats = <DateTime, int>{};
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      monthlyStats[date] = 0;
    }
    
    // Calculate actual test counts
    for (final test in tests) {
      if (test['test_date'] != null) {
        final testDate = DateTime.parse(test['test_date']);
        final testDay = DateTime(testDate.year, testDate.month, testDate.day);
        final testMonth = DateTime(testDate.year, testDate.month, 1);
        
        // Daily count
        if (dailyStats.containsKey(testDay)) {
          dailyStats[testDay] = dailyStats[testDay]! + 1;
        }
        
        // Monthly count
        if (monthlyStats.containsKey(testMonth)) {
          monthlyStats[testMonth] = monthlyStats[testMonth]! + 1;
        }
      }
    }
    
    // Calculate battery status (mock data for now)
    final batteryLevel = 50.0; // This could come from device data
    
    // Calculate usage statistics
    final totalTests = tests.length;
    final passedTests = tests.where((test) => test['test_status'] == 'passed').length;
    final usagePercentage = totalTests > 0 ? (passedTests / totalTests * 100).round() : 0;
    
    return {
      'dailyStats': dailyStats,
      'monthlyStats': monthlyStats,
      'batteryLevel': batteryLevel,
      'totalTests': totalTests,
      'passedTests': passedTests,
      'usagePercentage': usagePercentage,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: _isLoading
                ? AppComponents.loadingIndicator()
                : RefreshIndicator(
                    onRefresh: _loadDeviceStatistics,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Section
                          _buildOverviewSection(),
                          const SizedBox(height: 24),
                          
                          // Device Statistics Section
                          _buildDeviceStatisticsSection(),
                          const SizedBox(height: 24),
                          
                          // Number of Tests Section
                          _buildNumberOfTestsSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Overview',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 16),
                    Text(
              'DigiPICK™ i11',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primaryAccent,
                fontWeight: FontWeight.w600,
                fontSize: 24,
                      ),
            ),
          ],
                    ),
                    const SizedBox(height: 8),
        Container(
          width: 120,
          height: 2,
          color: AppColors.secondaryAccent,
        ),
        const SizedBox(height: 16),
        
        // Mac ID
                    Text(
          'Mac id : ${widget.device?['mac_address'] ?? '00-B0-D0-63-C2-26'}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiaryText,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // Battery Status
        _buildBatteryStatus(),
      ],
    );
  }

  Widget _buildBatteryStatus() {
    final batteryLevel = _statisticsData?['batteryLevel'] ?? 50.0;
    final batteryPercent = (batteryLevel / 100).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                Positioned(
                  right: -1,
                  top: 4,
                  child: Container(
                    width: 2,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Battery Status',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          
          // Battery percentage bar
                  Expanded(
            flex: 2,
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                        children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: batteryPercent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${batteryLevel.round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatisticsSection() {
    final totalTests = _statisticsData?['totalTests'] ?? 0;
    final passedTests = _statisticsData?['passedTests'] ?? 0;
    final usagePercentage = _statisticsData?['usagePercentage'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Statistics',
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
          'You\'re using $usagePercentage% of available requests.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.tertiaryText,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        
        // Circular Progress Chart
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(
                        value: passedTests.toDouble(),
                        color: AppColors.primaryAccent,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (totalTests - passedTests).toDouble(),
                        color: Colors.grey[200]!,
                        radius: 20,
                        showTitle: false,
                          ),
                        ],
                      ),
                ),
                Center(
                  child: Text(
                    '$passedTests/$totalTests',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Passed Tests', AppColors.primaryAccent),
            const SizedBox(width: 24),
            _buildLegendItem('Failed/Other', Colors.grey[400]!),
          ],
        ),
        const SizedBox(height: 16),
        
        Center(
          child: Text(
            totalTests > 0 
                ? 'You have used $usagePercentage% of your available requests. ${totalTests - passedTests} tests failed or incomplete.'
                : 'No test data available for this device yet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            color: AppColors.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberOfTestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of tests',
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        
        // Daily/Monthly Toggle
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton('Daily', isDaily),
              _buildToggleButton('Monthly', !isDaily),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Line Chart
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chart Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Tests Count', AppColors.primaryAccent),
                  const SizedBox(width: 16),
                  Text(
                    isDaily ? 'Last 7 Days' : 'Last 12 Months',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.tertiaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Chart
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxValue() / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 10,
                                color: AppColors.tertiaryText,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              _getBottomTitle(value.toInt()),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 10,
                                color: AppColors.tertiaryText,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey[300]!),
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getChartData(),
                        isCurved: true,
                        color: AppColors.primaryAccent,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primaryAccent,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryAccent.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: _getMaxValue(),
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isDaily = text == 'Daily';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.tertiaryText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getChartData() {
    if (_statisticsData == null) return [];
    
    if (isDaily) {
      final dailyStats = _statisticsData!['dailyStats'] as Map<DateTime, int>;
      final spots = <FlSpot>[];
      int index = 0;
      
      dailyStats.entries.forEach((entry) {
        spots.add(FlSpot(index.toDouble(), entry.value.toDouble()));
        index++;
      });
      
      return spots;
    } else {
      final monthlyStats = _statisticsData!['monthlyStats'] as Map<DateTime, int>;
      final spots = <FlSpot>[];
      int index = 0;
      
      monthlyStats.entries.forEach((entry) {
        spots.add(FlSpot(index.toDouble(), entry.value.toDouble()));
        index++;
      });
      
      return spots;
    }
  }

  double _getMaxValue() {
    final chartData = _getChartData();
    if (chartData.isEmpty) return 10;
    
    final maxValue = chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxValue + 5).ceilToDouble(); // Add some padding
  }

  String _getBottomTitle(int value) {
    if (_statisticsData == null) return '';
    
    if (isDaily) {
      final dailyStats = _statisticsData!['dailyStats'] as Map<DateTime, int>;
      final dates = dailyStats.keys.toList()..sort();
      
      if (value >= 0 && value < dates.length) {
        final date = dates[value];
        return '${date.day}/${date.month}';
      }
      return '';
    } else {
      final monthlyStats = _statisticsData!['monthlyStats'] as Map<DateTime, int>;
      final dates = monthlyStats.keys.toList()..sort();
      
      if (value >= 0 && value < dates.length) {
        final date = dates[value];
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[date.month - 1];
      }
      return '';
    }
  }
}
