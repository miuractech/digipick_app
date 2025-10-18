import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_test.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../services/download_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class ReportDetailScreen extends StatefulWidget {
  final DeviceTest report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late PageController _pageController;
  final AuthService _authService = AuthService();
  int _currentImageIndex = 0;
  bool _isRefreshing = false;
  late DeviceTest _currentReport;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentReport = widget.report;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Fetches the latest report data from the server
  Future<DeviceTest?> _fetchLatestReportData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) return null;

      // Get all device tests for the user and find the one with matching ID
      final allTests = await _authService.getDeviceTestsForUser(
        userId: authProvider.user!.id,
        limit: 1000, // Large limit to ensure we get all tests
      );

      // Find the test with matching ID
      final matchingTest = allTests.where((test) => test['id'] == _currentReport.id).firstOrNull;
      
      if (matchingTest != null) {
        return DeviceTest.fromJson(matchingTest);
      }
      
      return null;
    } catch (e) {
      print('Error fetching latest report data: $e');
      return null;
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Fetch the latest report data from the server
      final updatedReport = await _fetchLatestReportData();
      
      if (updatedReport != null) {
        // Update the current report with fresh data
        _currentReport = updatedReport;
        
        // Clear image cache to force reload of images
        final imageUrls = _getImageUrls();
        for (String imageUrl in imageUrls) {
          if (imageUrl.startsWith('http')) {
            try {
              // Clear network image cache
              await precacheImage(NetworkImage(imageUrl), context);
            } catch (e) {
              // Ignore individual image cache errors
            }
          }
        }
        
        if (mounted) {
          // Reset image carousel to first image with animation
          _currentImageIndex = 0;
          
          // Trigger a rebuild of the entire widget with new data
          setState(() {});
          
          // Animate to first image if carousel is available
          if (_pageController.hasClients && imageUrls.isNotEmpty) {
            await _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
          
          // Show success feedback
          AppComponents.showSuccessSnackbar(
            context,
            'Report data refreshed successfully',
          );
        }
      } else {
        // No updated data found
        if (mounted) {
          AppComponents.showErrorSnackbar(
            context,
            'No updated data found. Report may have been deleted.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Failed to refresh report. Please check your connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
            deviceName: _getDeviceName(),
            actions: [
              // Refresh button
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _isRefreshing ? Colors.grey[300] : AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isRefreshing ? Colors.grey[400]! : AppColors.primaryAccent,
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  onPressed: _isRefreshing ? null : _handleRefresh,
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          size: 20,
                          color: AppColors.primaryAccent,
                        ),
                  padding: EdgeInsets.zero,
                ),
              ),
              // PDF download button (if available)
              if (_isPdfAvailable())
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
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppColors.primaryAccent,
                  backgroundColor: Colors.white,
                  strokeWidth: 3,
                  displacement: 40,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        _buildTestResults(),
                        const SizedBox(height: 24),
                        _buildSampleSummary(),
                        const SizedBox(height: 100), // Extra space for better pull-to-refresh experience
                      ],
                    ),
                  ),
                ),
                // Subtle overlay during refresh
                if (_isRefreshing)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Refreshing report...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Report ${_currentReport.testDate != null ? "${_currentReport.testDate!.day.toString().padLeft(2, '0')}/${_currentReport.testDate!.month.toString().padLeft(2, '0')}/${_currentReport.testDate!.year.toString().substring(2)}" : ""} - ${_currentReport.id.substring(0, 3).toUpperCase()}',
      style: AppTextStyles.h1,
    );
  }

  Widget _buildBasicInfo() {
    final deviceName = _getDeviceName();
    return Column(
      children: [
        _buildInfoRow('Machine Detail', deviceName),
        _buildInfoRow('Time', _currentReport.testDate != null 
          ? "${_currentReport.testDate!.day.toString().padLeft(2, '0')}/${_currentReport.testDate!.month.toString().padLeft(2, '0')}/${_currentReport.testDate!.year.toString().substring(2)} - ${_currentReport.testDate!.hour.toString().padLeft(2, '0')}.${_currentReport.testDate!.minute.toString().padLeft(2, '0')}AM"
          : 'N/A'),
        _buildInfoRow('Report ID', _currentReport.id.substring(0, 12)),
        _buildInfoRow('Batch ID', _currentReport.folderName),
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
    
    if (imageUrls.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sample Images',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No images available',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Images',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: AnimatedImageCarousel(
            imageUrls: imageUrls,
            onImageTap: (index) => _showFullScreenImage(context, imageUrls, index),
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        ),
        if (imageUrls.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imageUrls.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentImageIndex == index
                      ? AppColors.primaryAccent
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSampleReadings() {
    final testResults = _currentReport.testResults;
    if (testResults == null) return const SizedBox.shrink();

    final imageUrls = _getImageUrls();
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final currentReading = _getCurrentImageReading();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Readings - ${_currentImageIndex + 1}',
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
              _buildReadingRow('Warp Count(A):', '${currentReading['countA']}'),
              _buildReadingRow('Weft Count(B):', '${currentReading['countB']}'),
              _buildReadingRow('Total Count(A+B):', '${currentReading['totalCount']}'),
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
    final testResults = _currentReport.testResults;
    if (testResults == null) return const SizedBox.shrink();
    
    final allReadings = _getAllImageReadings();
    
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
                      child: Text('Weft(B)', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ...allReadings.map((reading) => TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${reading['index'] + 1}'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${reading['countA']}'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${reading['countB']}'),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${reading['totalCount']}'),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestResults() {
    final testResults = _currentReport.testResults;
    if (testResults == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Results - Sample ${_currentImageIndex + 1}',
          style: const TextStyle(
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
                      child: Text('Weft(B)', style: TextStyle(fontWeight: FontWeight.bold)),
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

  /// Gets the reading for the current image index
  Map<String, dynamic> _getCurrentImageReading() {
    final imageUrls = _getImageUrls();
    if (_currentImageIndex < imageUrls.length) {
      final currentImageUrl = imageUrls[_currentImageIndex];
      
      // Try to match based on filename first
      final matchingReading = _getMatchingReading(currentImageUrl);
      if (matchingReading != null) {
        return {
          'countA': _extractNumericValue(matchingReading['warp'] ?? '0'),
          'countB': _extractNumericValue(matchingReading['weft'] ?? '0'),
          'totalCount': _extractNumericValue(matchingReading['total'] ?? '0'),
        };
      }
    }

    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['sampleReadings'] != null) {
      final sampleReadings = testResults['sampleReadings'] as List;
      if (sampleReadings.isNotEmpty && _currentImageIndex < sampleReadings.length) {
        final currentSampleGroup = sampleReadings[_currentImageIndex] as List;
        if (currentSampleGroup.isNotEmpty) {
          final reading = currentSampleGroup[0] as Map<String, dynamic>;
          return {
            'countA': _extractNumericValue(reading['warp'] ?? '0'),
            'countB': _extractNumericValue(reading['weft'] ?? '0'),
            'totalCount': _extractNumericValue(reading['total'] ?? '0'),
          };
        }
      }
    }
    
    // Fallback to sampleSummary if sampleReadings not available
    if (testResults != null && testResults['sampleSummary'] != null) {
      final sampleSummary = testResults['sampleSummary'] as List;
      if (sampleSummary.isNotEmpty && _currentImageIndex < sampleSummary.length) {
        final summary = sampleSummary[_currentImageIndex] as Map<String, dynamic>;
        return {
          'countA': _extractNumericValue(summary['warpA'] ?? '0'),
          'countB': _extractNumericValue(summary['weftB'] ?? '0'),
          'totalCount': _extractNumericValue(summary['totalAB'] ?? '0'),
        };
      }
    }
    
    return {'countA': 0, 'countB': 0, 'totalCount': 0};
  }

  /// Helper method to extract numeric value from string with units
  int _extractNumericValue(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      // Extract numeric part from strings like "56/inch" or "127/inch²"
      final match = RegExp(r'(\d+)').firstMatch(value);
      return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
    }
    return 0;
  }

  /// Helper method to extract filename from full path or URL
  String _extractFilename(String path) {
    return path.split('/').last;
  }

  /// Helper method to match image URL with sample reading based on filename
  Map<String, dynamic>? _getMatchingReading(String imageUrl) {
    final testResults = _currentReport.testResults;
    if (testResults == null || testResults['sampleReadings'] == null) return null;

    final imageFilename = _extractFilename(imageUrl);
    final sampleReadings = testResults['sampleReadings'] as List;

    // Search through all sample readings for matching filename
    for (var readingGroup in sampleReadings) {
      if (readingGroup is List) {
        for (var reading in readingGroup) {
          if (reading is Map<String, dynamic> && reading['img'] != null) {
            final readingFilename = _extractFilename(reading['img']);
            if (readingFilename == imageFilename) {
              return reading;
            }
          }
        }
      }
    }

    return null;
  }

  /// Gets all readings for the sample summary table
  List<Map<String, dynamic>> _getAllImageReadings() {
    final testResults = _currentReport.testResults;
    final List<Map<String, dynamic>> allReadings = [];
    final imageUrls = _getImageUrls();
    
    // Prioritize sampleSummary as requested by user
    if (testResults != null && testResults['sampleSummary'] != null) {
      final sampleSummary = testResults['sampleSummary'] as List;
      for (int i = 0; i < sampleSummary.length; i++) {
        final summary = sampleSummary[i] as Map<String, dynamic>;
        allReadings.add({
          'index': i,
          'countA': _extractNumericValue(summary['warpA'] ?? '0'),
          'countB': _extractNumericValue(summary['weftB'] ?? '0'),
          'totalCount': _extractNumericValue(summary['totalAB'] ?? '0'),
        });
      }
      return allReadings;
    }

    // Fallback: Try to match images with sampleReadings based on filename
    if (testResults != null && testResults['sampleReadings'] != null && imageUrls.isNotEmpty) {
      for (int i = 0; i < imageUrls.length; i++) {
        final imageUrl = imageUrls[i];
        final matchingReading = _getMatchingReading(imageUrl);
        
        if (matchingReading != null) {
          allReadings.add({
            'index': i,
            'countA': _extractNumericValue(matchingReading['warp'] ?? '0'),
            'countB': _extractNumericValue(matchingReading['weft'] ?? '0'),
            'totalCount': _extractNumericValue(matchingReading['total'] ?? '0'),
          });
        }
      }
      
      if (allReadings.isNotEmpty) return allReadings;
    }

    // Final fallback: Use sampleReadings by index
    if (testResults != null && testResults['sampleReadings'] != null) {
      final sampleReadings = testResults['sampleReadings'] as List;
      for (int i = 0; i < sampleReadings.length; i++) {
        final readingGroup = sampleReadings[i] as List;
        if (readingGroup.isNotEmpty) {
          final reading = readingGroup[0] as Map<String, dynamic>;
          allReadings.add({
            'index': i,
            'countA': _extractNumericValue(reading['warp'] ?? '0'),
            'countB': _extractNumericValue(reading['weft'] ?? '0'),
            'totalCount': _extractNumericValue(reading['total'] ?? '0'),
          });
        }
      }
    }
    
    return allReadings;
  }

  String _getDeviceName() {
    if (_currentReport.metadata != null && _currentReport.metadata!['device_name'] != null) {
      return _currentReport.metadata!['device_name'];
    }
    return _currentReport.deviceName ?? 'N/A';
  }

  List<String> _getImageUrls() {
    if (_currentReport.metadata != null && _currentReport.metadata!['image_urls'] != null) {
      return List<String>.from(_currentReport.metadata!['image_urls']);
    }
    return _currentReport.images;
  }

  String _getSampleType() {
    return 'Natural White (600 DNR)';
  }


  Map<String, String> _getMeanValues() {
    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['testResults'] != null) {
      final results = testResults['testResults'] as List;
      if (results.isNotEmpty && _currentImageIndex < results.length && results[_currentImageIndex] is List) {
        final currentGroup = results[_currentImageIndex] as List;
        for (var result in currentGroup) {
          if (result is Map<String, dynamic> && result['type'] == 'Mean') {
            return {
              'warpA': '${result['warpA'] ?? 0}',
              'warpB': '${result['weftB'] ?? 0}',
              'total': '${result['totalAB'] ?? 0}',
            };
          }
        }
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getStdDeviationValues() {
    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['testResults'] != null) {
      final results = testResults['testResults'] as List;
      if (results.isNotEmpty && _currentImageIndex < results.length && results[_currentImageIndex] is List) {
        final currentGroup = results[_currentImageIndex] as List;
        for (var result in currentGroup) {
          if (result is Map<String, dynamic> && result['type'] == 'Standard Deviation') {
            return {
              'warpA': '${result['warpA'] ?? 0}',
              'warpB': '${result['weftB'] ?? 0}',
              'total': '${result['totalAB'] ?? 0}',
            };
          }
        }
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getCoeffVariationValues() {
    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['testResults'] != null) {
      final results = testResults['testResults'] as List;
      if (results.isNotEmpty && _currentImageIndex < results.length && results[_currentImageIndex] is List) {
        final currentGroup = results[_currentImageIndex] as List;
        for (var result in currentGroup) {
          if (result is Map<String, dynamic> && result['type'] == 'Coefficient of Variation') {
            return {
              'warpA': '${result['warpA'] ?? 0}',
              'warpB': '${result['weftB'] ?? 0}',
              'total': '${result['totalAB'] ?? 0}',
            };
          }
        }
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getMinValues() {
    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['testResults'] != null) {
      final results = testResults['testResults'] as List;
      if (results.isNotEmpty && _currentImageIndex < results.length && results[_currentImageIndex] is List) {
        final currentGroup = results[_currentImageIndex] as List;
        for (var result in currentGroup) {
          if (result is Map<String, dynamic> && result['type'] == 'Minimum') {
            return {
              'warpA': '${result['warpA'] ?? 0}',
              'warpB': '${result['weftB'] ?? 0}',
              'total': '${result['totalAB'] ?? 0}',
            };
          }
        }
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getMaxValues() {
    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['testResults'] != null) {
      final results = testResults['testResults'] as List;
      if (results.isNotEmpty && _currentImageIndex < results.length && results[_currentImageIndex] is List) {
        final currentGroup = results[_currentImageIndex] as List;
        for (var result in currentGroup) {
          if (result is Map<String, dynamic> && result['type'] == 'Maximum') {
            return {
              'warpA': '${result['warpA'] ?? 0}',
              'warpB': '${result['weftB'] ?? 0}',
              'total': '${result['totalAB'] ?? 0}',
            };
          }
        }
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  Map<String, String> _getRangeValues() {
    final testResults = _currentReport.testResults;
    if (testResults != null && testResults['testResults'] != null) {
      final results = testResults['testResults'] as List;
      if (results.isNotEmpty && _currentImageIndex < results.length && results[_currentImageIndex] is List) {
        final currentGroup = results[_currentImageIndex] as List;
        for (var result in currentGroup) {
          if (result is Map<String, dynamic> && result['type'] == 'Range') {
            return {
              'warpA': '${result['warpA'] ?? 0}',
              'warpB': '${result['weftB'] ?? 0}',
              'total': '${result['totalAB'] ?? 0}',
            };
          }
        }
      }
    }
    return {'warpA': '0', 'warpB': '0', 'total': '0'};
  }

  /// Checks if PDF is available for this report
  bool _isPdfAvailable() {
    return _currentReport.pdfUrl != null && _currentReport.pdfUrl!.isNotEmpty;
  }

  /// Downloads the PDF report for this device test
  Future<void> _downloadPdf(BuildContext context) async {
    final pdfUrl = _currentReport.pdfUrl;
    
    if (pdfUrl == null || pdfUrl.isEmpty) {
      AppComponents.showErrorSnackbar(
        context,
        'PDF not available for this report',
      );
      return;
    }

    // Generate a meaningful filename
    final timestamp = _currentReport.testDate != null 
        ? "${_currentReport.testDate!.day.toString().padLeft(2, '0')}-${_currentReport.testDate!.month.toString().padLeft(2, '0')}-${_currentReport.testDate!.year}"
        : DateTime.now().toString().substring(0, 10);
    
    final deviceName = _getDeviceName().replaceAll(' ', '_').toLowerCase();
    final fileName = 'Report_${deviceName}_${timestamp}_${_currentReport.id.substring(0, 8)}';

    // Download the PDF
    await DownloadService.downloadPdf(
      pdfUrl: pdfUrl,
      fileName: fileName,
      context: context,
    );
  }

  void _showFullScreenImage(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class AnimatedImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Function(int) onImageTap;
  final Function(int) onPageChanged;

  const AnimatedImageCarousel({
    super.key,
    required this.imageUrls,
    required this.onImageTap,
    required this.onPageChanged,
  });

  @override
  State<AnimatedImageCarousel> createState() => _AnimatedImageCarouselState();
}

class _AnimatedImageCarouselState extends State<AnimatedImageCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.65,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        widget.onPageChanged(index);
        _animationController.forward().then((_) {
          _animationController.reset();
        });
      },
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        return _buildCarouselItem(index);
      },
    );
  }

  Widget _buildCarouselItem(int index) {
    double offset = (_currentPage - index).abs();
    
    // Adjust scaling to be less aggressive - side images should be more visible
    double scale = 1.0 - (offset * 0.15).clamp(0.0, 0.15);
    
    // Reduce opacity reduction - side images should be clearly visible
    double opacity = 1.0 - (offset * 0.25).clamp(0.0, 0.25);
    
    // Adjust vertical positioning for depth effect
    double verticalOffset = offset * 15;
    
    return Container(
      margin: EdgeInsets.only(
        left: 4,
        right: 4,
        top: verticalOffset,
        bottom: verticalOffset,
      ),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: GestureDetector(
            onTap: () => widget.onImageTap(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(offset < 0.5 ? 0.25 : 0.15),
                    blurRadius: offset < 0.5 ? 20 : 10,
                    offset: Offset(0, offset < 0.5 ? 10 : 5),
                    spreadRadius: offset < 0.5 ? 3 : 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Main image
                    widget.imageUrls[index].startsWith('http')
                        ? Image.network(
                            widget.imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.grey[200]!,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey[100]!,
                                      Colors.grey[50]!,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / 
                                                loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 3,
                                          color: AppColors.primaryAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Loading...',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[300]!,
                                  Colors.grey[200]!,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                    
                    // Subtle overlay for non-center images to create depth
                    if (offset > 0.3)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    
                    // Active indicator for center image
                    if (offset < 0.3)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} of ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.imageUrls.length > 1
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
