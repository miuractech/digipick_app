import 'package:flutter/material.dart';
import '../models/device_test.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../services/download_service.dart';

class ReportDetailScreen extends StatelessWidget {
  final DeviceTest report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
            actions: _isPdfAvailable() ? [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _downloadPdf(context),
                  icon: const Icon(
                    Icons.download,
                    size: 20,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ] : [],
          ),
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildSampleImages(),
            const SizedBox(height: 24),
            _buildSampleReadings(),
            const SizedBox(height: 24),
            _buildSampleSummary(),
            const SizedBox(height: 24),
            _buildTestResults(),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Report ${report.testDate != null ? "${report.testDate!.day.toString().padLeft(2, '0')}/${report.testDate!.month.toString().padLeft(2, '0')}/${report.testDate!.year.toString().substring(2)}" : ""} - ${report.id.substring(0, 3).toUpperCase()}',
      style: AppTextStyles.h1,
    );
  }

  Widget _buildBasicInfo() {
    final deviceName = _getDeviceName();
    return Column(
      children: [
        _buildInfoRow('Machine Detail', deviceName),
        _buildInfoRow('Time', report.testDate != null 
          ? "${report.testDate!.day.toString().padLeft(2, '0')}/${report.testDate!.month.toString().padLeft(2, '0')}/${report.testDate!.year.toString().substring(2)} - ${report.testDate!.hour.toString().padLeft(2, '0')}.${report.testDate!.minute.toString().padLeft(2, '0')}AM"
          : 'N/A'),
        _buildInfoRow('Report ID', report.id.substring(0, 12)),
        _buildInfoRow('Batch ID', report.uploadBatch?.substring(6) ?? 'N/A'),
        _buildInfoRow('Test Gauge (LT)', '1 inch^2'),
        _buildInfoRow('Sample Type', _getSampleType()),
        _buildInfoRow('Test Material', 'Cotton'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleImages() {
    final imageUrls = _getImageUrls();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Images',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length > 0 ? imageUrls.length : 3,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: AppBorderRadius.button,
                ),
                child: imageUrls.length > index && imageUrls[index].startsWith('http')
                    ? ClipRRect(
                        borderRadius: AppBorderRadius.button,
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSampleReadings() {
    final testResults = report.testResults;
    if (testResults == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Readings - 1',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Column(
            children: [
              _buildReadingRow('Warp Count(A):', _getWarpCount()),
              _buildReadingRow('Weft Count(B):', _getWeftCount()),
              _buildReadingRow('Total Count(A+B):', _getTotalCount()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sample Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Table(
            border: TableBorder.all(color: Colors.grey[200]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]),
                children: const [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('SampleCount', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Warp(A)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Warp(B)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Total(A+B)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('1'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('0'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('0'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('0'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestResults() {
    final testResults = report.testResults;
    if (testResults == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Table(
            border: TableBorder.all(color: Colors.grey[200]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[50]),
                children: const [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Result Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Warp(A)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Warp(B)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Total(A+B)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              _buildResultRow('Mean', _getMeanValues()),
              _buildResultRow('Std Deviation', _getStdDeviationValues()),
              _buildResultRow('Coeff of Variation', _getCoeffVariationValues()),
              _buildResultRow('Minimum', _getMinValues()),
              _buildResultRow('Maximum', _getMaxValues()),
              _buildResultRow('Range', _getRangeValues()),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildResultRow(String label, Map<String, String> values) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(label),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(values['warpA'] ?? '0'),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(values['warpB'] ?? '0'),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(values['total'] ?? '0'),
          ),
        ),
      ],
    );
  }

  String _getDeviceName() {
    if (report.metadata != null && report.metadata!['device_name'] != null) {
      return report.metadata!['device_name'];
    }
    return report.deviceName ?? 'N/A';
  }

  List<String> _getImageUrls() {
    if (report.metadata != null && report.metadata!['image_urls'] != null) {
      return List<String>.from(report.metadata!['image_urls']);
    }
    return report.images;
  }

  String _getSampleType() {
    return 'Natural White (600 DNR)';
  }

  String _getWarpCount() {
    final testResults = report.testResults;
    if (testResults != null && testResults['mean'] != null) {
      final mean = testResults['mean'] as List;
      if (mean.isNotEmpty && mean[0] is List) {
        return '${(mean[0] as List)[0]} inch^2';
      }
    }
    return '44 inch^2';
  }

  String _getWeftCount() {
    final testResults = report.testResults;
    if (testResults != null && testResults['mean'] != null) {
      final mean = testResults['mean'] as List;
      if (mean.isNotEmpty && mean[0] is List && (mean[0] as List).length > 1) {
        return '${(mean[0] as List)[1]}inch^2';
      }
    }
    return '55inch^2';
  }

  String _getTotalCount() {
    final testResults = report.testResults;
    if (testResults != null && testResults['mean'] != null) {
      final mean = testResults['mean'] as List;
      if (mean.isNotEmpty && mean[0] is List && (mean[0] as List).length > 2) {
        return '${(mean[0] as List)[2]}inch^2';
      }
    }
    return '99inch^2';
  }

  Map<String, String> _getMeanValues() {
    final testResults = report.testResults;
    if (testResults != null && testResults['mean'] != null) {
      final mean = testResults['mean'] as List;
      if (mean.isNotEmpty && mean[0] is List) {
        final values = mean[0] as List;
        return {
          'warpA': values.length > 0 ? '${values[0]} inch2' : '64 inch2',
          'warpB': values.length > 1 ? '${values[1]} inch' : '112 inch',
          'total': values.length > 2 ? '${values[2]} inch' : '176 inch',
        };
      }
    }
    return {'warpA': '64 inch2', 'warpB': '112 inch', 'total': '176 inch'};
  }

  Map<String, String> _getStdDeviationValues() {
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getCoeffVariationValues() {
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getMinValues() {
    final testResults = report.testResults;
    if (testResults != null && testResults['min'] != null) {
      final min = testResults['min'] as List;
      if (min.isNotEmpty && min[0] is List) {
        final values = min[0] as List;
        return {
          'warpA': values.length > 0 ? '${values[0]}' : '64',
          'warpB': values.length > 1 ? '${values[1]}' : '112',
          'total': values.length > 2 ? '${values[2]}' : '176',
        };
      }
    }
    return {'warpA': '64', 'warpB': '112', 'total': '176'};
  }

  Map<String, String> _getMaxValues() {
    final testResults = report.testResults;
    if (testResults != null && testResults['max'] != null) {
      final max = testResults['max'] as List;
      if (max.isNotEmpty && max[0] is List) {
        final values = max[0] as List;
        return {
          'warpA': values.length > 0 ? '${values[0]}' : '64',
          'warpB': values.length > 1 ? '${values[1]}' : '112',
          'total': values.length > 2 ? '${values[2]}' : '176',
        };
      }
    }
    return {'warpA': '64', 'warpB': '112', 'total': '176'};
  }

  Map<String, String> _getRangeValues() {
    final testResults = report.testResults;
    if (testResults != null && testResults['range'] != null) {
      final range = testResults['range'] as List;
      if (range.isNotEmpty && range[0] is List) {
        final values = range[0] as List;
        return {
          'warpA': values.length > 0 ? '${values[0]}' : '0',
          'warpB': values.length > 1 ? '${values[1]}' : '0',
          'total': values.length > 2 ? '${values[2]}' : '0',
        };
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  /// Checks if PDF is available for this report
  bool _isPdfAvailable() {
    return report.pdfUrl != null && report.pdfUrl!.isNotEmpty;
  }

  /// Downloads the PDF report for this device test
  Future<void> _downloadPdf(BuildContext context) async {
    final pdfUrl = report.pdfUrl;
    
    if (pdfUrl == null || pdfUrl.isEmpty) {
      AppComponents.showErrorSnackbar(
        context,
        'PDF not available for this report',
      );
      return;
    }

    // Generate a meaningful filename
    final timestamp = report.testDate != null 
        ? "${report.testDate!.day.toString().padLeft(2, '0')}-${report.testDate!.month.toString().padLeft(2, '0')}-${report.testDate!.year}"
        : DateTime.now().toString().substring(0, 10);
    
    final deviceName = _getDeviceName().replaceAll(' ', '_').toLowerCase();
    final fileName = 'Report_${deviceName}_${timestamp}_${report.id.substring(0, 8)}';

    // Download the PDF
    await DownloadService.downloadPdf(
      pdfUrl: pdfUrl,
      fileName: fileName,
      context: context,
    );
  }
}
