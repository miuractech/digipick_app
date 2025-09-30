import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_test.dart';
import '../services/auth_service.dart';
import '../services/download_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'report_detail_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ReportsPage extends StatefulWidget {
  final String? deviceId;
  
  const ReportsPage({super.key, this.deviceId});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  
  List<DeviceTest> _reports = [];
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  int _totalReportsCount = 0;
  
  // Filters
  String? _selectedDeviceId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Sorting
  String _sortBy = 'date'; // 'date', 'name', 'status'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Set initial device filter if provided
    if (widget.deviceId != null) {
      _selectedDeviceId = widget.deviceId;
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReports();
    }
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await Future.wait([
        _loadDevices(authProvider.user!.id),
        _loadReports(reset: true),
      ]);
    }
  }

  Future<void> _loadDevices(String userId) async {
    final devices = await _authService.getDevicesForUser(userId);
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _loadReports({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 0;
        _hasMore = true;
        _reports.clear();
        _totalReportsCount = 0;
      }
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.organization == null) return;

    try {
      // For default load (no filters), get last 10 reports initially
      final isDefaultLoad = _selectedDeviceId == null && 
                           _selectedStatus == null && 
                           _startDate == null && 
                           _endDate == null;
      
      final currentLimit = isDefaultLoad && _currentPage == 0 ? 10 : _pageSize;
      final currentOffset = _currentPage == 0 && isDefaultLoad 
          ? 0 
          : (_currentPage == 0 ? 0 : (_currentPage - 1) * _pageSize + (isDefaultLoad ? 10 : 0));
      
      // Fix: Adjust end date to include the full day (23:59:59.999)
      DateTime? adjustedEndDate = _endDate;
      if (_endDate != null) {
        adjustedEndDate = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
          999,
        );
      }
      
      final reportsData = await _authService.getDeviceTestsForUser(
        userId: authProvider.user!.id,
        deviceId: _selectedDeviceId,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: adjustedEndDate,
        limit: currentLimit,
        offset: currentOffset,
      );

      final newReports = reportsData.map((data) => DeviceTest.fromJson(data)).toList();

      // Get total count for display (only on first load or filter change)
      if (reset) {
        final totalCountData = await _authService.getDeviceTestsForUser(
          userId: authProvider.user!.id,
          deviceId: _selectedDeviceId,
          status: _selectedStatus,
          startDate: _startDate,
          endDate: adjustedEndDate,
          limit: 1000, // Large number to get total count
          offset: 0,
        );
        _totalReportsCount = totalCountData.length;
      }

      setState(() {
        _reports.addAll(newReports);
        _currentPage++;
        _hasMore = newReports.length == currentLimit;
        _isLoading = false;
      });

      // Apply sorting after loading
      if (_reports.isNotEmpty) {
        _applySorting();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreReports() async {
    await _loadReports();
  }

  void _applyFilters() {
    _loadReports(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
          ),
          // Action buttons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Sort button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSortOptions,
                    icon: const Icon(Icons.sort, size: 20),
                    label: Text('${_getSortDisplayName()}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryText,
                      elevation: 1,
                      side: BorderSide(color: AppColors.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showFilterModal,
                    icon: Icon(
                      Icons.filter_list, 
                      size: 20,
                      color: _hasActiveFilters() ? AppColors.primaryAccent : AppColors.primaryText,
                    ),
                    label: Text(_hasActiveFilters() ? 'Filtered' : 'Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasActiveFilters() ? AppColors.primaryAccent.withOpacity(0.1) : Colors.white,
                      foregroundColor: _hasActiveFilters() ? AppColors.primaryAccent : AppColors.primaryText,
                      elevation: 1,
                      side: BorderSide(
                        color: _hasActiveFilters() ? AppColors.primaryAccent : AppColors.dividerColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Refresh button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await _loadReports(reset: true);
                    },
                    icon: const Icon(Icons.refresh, size: 24),
                    color: AppColors.primaryText,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          // Total count display
          if (_totalReportsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Total Reports: $_totalReportsCount',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadReports(reset: true);
                },
                child: _buildReportsList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Sort By', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              _buildSortOption('Date', 'date', Icons.calendar_today),
              _buildSortOption('Status', 'status', Icons.flag),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.sort, color: AppColors.primaryText),
                  const SizedBox(width: 8),
                  Text('Order: ', style: AppTextStyles.bodyLarge),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                      _applySorting();
                      Navigator.pop(context);
                    },
                    icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                    label: Text(_sortAscending ? 'Ascending' : 'Descending'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryAccent : AppColors.tertiaryText),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected ? AppColors.primaryAccent : AppColors.primaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryAccent) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _applySorting();
        Navigator.pop(context);
      },
    );
  }

  void _applySorting() {
    setState(() {
      _reports.sort((a, b) {
        int comparison = 0;
        switch (_sortBy) {
          case 'date':
            comparison = (a.testDate ?? DateTime(1970)).compareTo(b.testDate ?? DateTime(1970));
            break;
          case 'status':
            comparison = (a.testStatus ?? '').compareTo(b.testStatus ?? '');
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  String _getSortDisplayName() {
    switch (_sortBy) {
      case 'date':
        return 'Date';
      case 'status':
        return 'Status';
      default:
        return 'Date';
    }
  }

  bool _hasActiveFilters() {
    return _selectedDeviceId != null ||
           _selectedStatus != null ||
           _startDate != null ||
           _endDate != null;
  }

  void _showFilterModal() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => FilterModal(
        selectedDeviceId: _selectedDeviceId,
        selectedStatus: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        devices: _devices,
        onApply: (deviceId, status, start, end) {
          setState(() {
            _selectedDeviceId = deviceId;
            _selectedStatus = status;
            _startDate = start;
            _endDate = end;
          });
          _applyFilters();
          Navigator.of(context).pop();
        },
        onClear: () {
          setState(() {
            _selectedDeviceId = null;
            _selectedStatus = null;
            _startDate = null;
            _endDate = null;
          });
          _applyFilters();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildReportsList() {
    if (_reports.isEmpty && _isLoading) {
      return AppComponents.loadingIndicator();
    }

    if (_reports.isEmpty && !_isLoading) {
      final hasFiltersApplied = _selectedDeviceId != null || 
                                _selectedStatus != null || 
                                _startDate != null || 
                                _endDate != null;
      
      return AppComponents.emptyState(
        icon: Icons.assessment_outlined,
        title: hasFiltersApplied ? 'No reports found' : 'No reports available',
        subtitle: hasFiltersApplied 
            ? 'Try adjusting your filters to see more results'
            : 'Reports will appear here once device tests are completed',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _reports.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _reports.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: AppComponents.loadingIndicator(),
          );
        }

        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(DeviceTest report) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Images icon from assets
            Container(
              width: 60,
              height: 60,
              child: Image.asset(
                'lib/assets/images.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 24),
            // Report content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report : ${report.folderName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (report.testDate != null)
                    Text(
                      'Date : ${report.testDate!.day} ${_getMonthName(report.testDate!.month)} ${report.testDate!.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportDetailScreen(report: report),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF245C9E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Only show download button if PDF URL exists
                      if (_isPdfAvailable(report)) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _downloadPdf(report, context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Download',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  /// Checks if PDF is available for the given report
  bool _isPdfAvailable(DeviceTest report) {
    return report.pdfUrl != null && report.pdfUrl!.isNotEmpty;
  }

  /// Downloads the PDF report for the given device test
  Future<void> _downloadPdf(DeviceTest report, BuildContext context) async {
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
    
    final deviceName = (report.deviceName ?? 'unknown').replaceAll(' ', '_').toLowerCase();
    final fileName = 'Report_${deviceName}_${timestamp}_${report.id.substring(0, 8)}';

    // Download the PDF
    await DownloadService.downloadPdf(
      pdfUrl: pdfUrl,
      fileName: fileName,
      context: context,
    );
  }
}

class FilterModal extends StatefulWidget {
  final String? selectedDeviceId;
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Map<String, dynamic>> devices;
  final void Function(String?, String?, DateTime?, DateTime?) onApply;
  final VoidCallback onClear;

  const FilterModal({
    super.key,
    required this.selectedDeviceId,
    required this.selectedStatus,
    required this.startDate,
    required this.endDate,
    required this.devices,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _selectedDeviceId;
  String? _selectedStatus;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedDeviceId = widget.selectedDeviceId;
    _selectedStatus = widget.selectedStatus;
    if (widget.startDate != null && widget.endDate != null) {
      _dateRange = DateTimeRange(start: widget.startDate!, end: widget.endDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                ),
              ),
              Text('Filters', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedDeviceId,
                decoration: InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.input,
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  isDense: true,
                  labelStyle: AppTextStyles.bodyMedium,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Devices'),
                  ),
                  ...widget.devices.map((device) => DropdownMenuItem<String>(
                    value: device['id'],
                    child: Text(device['device_name'] ?? 'Unknown Device'),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.input,
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  isDense: true,
                  labelStyle: AppTextStyles.bodyMedium,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Status'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'passed',
                    child: Text('Passed'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'failed',
                    child: Text('Failed'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'incomplete',
                    child: Text('Incomplete'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Date Range', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: _dateRange,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRange = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.dividerColor),
                    borderRadius: AppBorderRadius.input,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.tertiaryText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dateRange == null
                              ? 'Select date range'
                              : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _selectedDeviceId,
                          _selectedStatus,
                          _dateRange?.start,
                          _dateRange?.end,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onClear,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryText,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                      child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

