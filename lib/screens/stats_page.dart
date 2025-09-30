import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../services/auth_service.dart';

enum FilterPeriod {
  daily,
  weekly, 
  monthly,
  yearly,
  custom
}

class StatsPage extends StatefulWidget {
  final Map<String, dynamic>? device;

  const StatsPage({super.key, this.device});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  FilterPeriod _selectedPeriod = FilterPeriod.daily;
  DateTimeRange? _customDateRange;
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
    
    Map<DateTime, int> periodStats = {};
    
    // Generate date ranges based on selected period
    switch (_selectedPeriod) {
      case FilterPeriod.daily:
        for (int i = 6; i >= 0; i--) {
          final date = today.subtract(Duration(days: i));
          periodStats[date] = 0;
        }
        break;
        
      case FilterPeriod.weekly:
        // Last 8 weeks
        for (int i = 7; i >= 0; i--) {
          final date = today.subtract(Duration(days: i * 7));
          final weekStart = date.subtract(Duration(days: date.weekday - 1));
          periodStats[weekStart] = 0;
        }
        break;
        
      case FilterPeriod.monthly:
        for (int i = 11; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          periodStats[date] = 0;
        }
        break;
        
      case FilterPeriod.yearly:
        // Last 5 years
        for (int i = 4; i >= 0; i--) {
          final date = DateTime(now.year - i, 1, 1);
          periodStats[date] = 0;
        }
        break;
        
      case FilterPeriod.custom:
        if (_customDateRange != null) {
          final fromDate = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          final toDate = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day);
          final diffDays = toDate.difference(fromDate).inDays;
          
          if (diffDays <= 31) {
            // Show daily for ranges <= 31 days
            for (int i = 0; i <= diffDays; i++) {
              final date = fromDate.add(Duration(days: i));
              periodStats[date] = 0;
            }
          } else if (diffDays <= 365) {
            // Show weekly for ranges <= 1 year
            DateTime currentDate = fromDate;
            while (currentDate.isBefore(toDate) || currentDate.isAtSameMomentAs(toDate)) {
              final weekStart = currentDate.subtract(Duration(days: currentDate.weekday - 1));
              periodStats[weekStart] = 0;
              currentDate = currentDate.add(const Duration(days: 7));
            }
          } else {
            // Show monthly for longer ranges
            DateTime currentDate = DateTime(fromDate.year, fromDate.month, 1);
            final endDate = DateTime(toDate.year, toDate.month, 1);
            while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
              periodStats[currentDate] = 0;
              currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
            }
          }
        }
        break;
    }
    
    // Calculate actual test counts
    for (final test in tests) {
      if (test['test_date'] != null) {
        final testDate = DateTime.parse(test['test_date']);
        DateTime periodKey;
        
        switch (_selectedPeriod) {
          case FilterPeriod.daily:
            periodKey = DateTime(testDate.year, testDate.month, testDate.day);
            break;
            
          case FilterPeriod.weekly:
            periodKey = testDate.subtract(Duration(days: testDate.weekday - 1));
            periodKey = DateTime(periodKey.year, periodKey.month, periodKey.day);
            break;
            
          case FilterPeriod.monthly:
            periodKey = DateTime(testDate.year, testDate.month, 1);
            break;
            
          case FilterPeriod.yearly:
            periodKey = DateTime(testDate.year, 1, 1);
            break;
            
          case FilterPeriod.custom:
            if (_customDateRange != null) {
              final fromDate = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
              final toDate = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day);
              final diffDays = toDate.difference(fromDate).inDays;
              
              if (diffDays <= 31) {
                periodKey = DateTime(testDate.year, testDate.month, testDate.day);
              } else if (diffDays <= 365) {
                final weekStart = testDate.subtract(Duration(days: testDate.weekday - 1));
                periodKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
              } else {
                periodKey = DateTime(testDate.year, testDate.month, 1);
              }
            } else {
              continue;
            }
            break;
        }
        
        if (periodStats.containsKey(periodKey)) {
          periodStats[periodKey] = periodStats[periodKey]! + 1;
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
      'periodStats': periodStats,
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
        
        // Filter Options
        _buildFilterOptions(),
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
                    _getPeriodDescription(),
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

  Widget _buildFilterOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterButton('Daily', FilterPeriod.daily),
        _buildFilterButton('Weekly', FilterPeriod.weekly),
        _buildFilterButton('Monthly', FilterPeriod.monthly),
        _buildFilterButton('Yearly', FilterPeriod.yearly),
        _buildFilterButton('Custom', FilterPeriod.custom),
      ],
    );
  }

  Widget _buildFilterButton(String text, FilterPeriod period) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () async {
        if (period == FilterPeriod.custom) {
          final picked = await showDateRangePicker(
            context: context,
            initialDateRange: _customDateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _selectedPeriod = period;
              _customDateRange = picked;
            });
            _loadDeviceStatistics();
          }
        } else {
          setState(() {
            _selectedPeriod = period;
            _customDateRange = null;
          });
          _loadDeviceStatistics();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.tertiaryText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _getPeriodDescription() {
    switch (_selectedPeriod) {
      case FilterPeriod.daily:
        return 'Last 7 Days';
      case FilterPeriod.weekly:
        return 'Last 8 Weeks';
      case FilterPeriod.monthly:
        return 'Last 12 Months';
      case FilterPeriod.yearly:
        return 'Last 5 Years';
      case FilterPeriod.custom:
        if (_customDateRange != null) {
          return 'Custom Range: ${_customDateRange!.start.day}/${_customDateRange!.start.month}/${_customDateRange!.start.year} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}/${_customDateRange!.end.year}';
        }
        return 'Custom Range';
    }
  }

  List<FlSpot> _getChartData() {
    if (_statisticsData == null) return [];
    
    final periodStats = _statisticsData!['periodStats'] as Map<DateTime, int>;
    final spots = <FlSpot>[];
    
    // Sort dates and create spots
    final sortedEntries = periodStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    for (int i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value.toDouble()));
    }
    
    return spots;
  }

  double _getMaxValue() {
    final chartData = _getChartData();
    if (chartData.isEmpty) return 10;
    
    final maxValue = chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxValue + 5).ceilToDouble(); // Add some padding
  }

  String _getBottomTitle(int value) {
    if (_statisticsData == null) return '';
    
    final periodStats = _statisticsData!['periodStats'] as Map<DateTime, int>;
    final dates = periodStats.keys.toList()..sort();
    
    if (value >= 0 && value < dates.length) {
      final date = dates[value];
      
      switch (_selectedPeriod) {
        case FilterPeriod.daily:
          return '${date.day}/${date.month}';
          
        case FilterPeriod.weekly:
          return '${date.day}/${date.month}';
          
        case FilterPeriod.monthly:
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return months[date.month - 1];
          
        case FilterPeriod.yearly:
          return date.year.toString();
          
        case FilterPeriod.custom:
          if (_customDateRange != null) {
            final fromDate = DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
            final toDate = DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day);
            final diffDays = toDate.difference(fromDate).inDays;
            
            if (diffDays <= 31) {
              return '${date.day}/${date.month}';
            } else if (diffDays <= 365) {
              return '${date.day}/${date.month}';
            } else {
              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              return months[date.month - 1];
            }
          }
          return '${date.day}/${date.month}';
      }
    }
    return '';
  }
}
