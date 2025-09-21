import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_test.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'report_detail_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

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
  
  // Filters
  String? _selectedDeviceId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    if (authProvider.organization != null) {
      await Future.wait([
        _loadDevices(authProvider.organization!['id']),
        _loadReports(reset: true),
      ]);
    }
  }

  Future<void> _loadDevices(String companyId) async {
    final devices = await _authService.getDevicesForOrganization(companyId);
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
      }
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.organization == null) return;

    try {
      final reportsData = await _authService.getDeviceTests(
        companyId: authProvider.organization!['id'],
        deviceId: _selectedDeviceId,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      final newReports = reportsData.map((data) => DeviceTest.fromJson(data)).toList();

      setState(() {
        _reports.addAll(newReports);
        _currentPage++;
        _hasMore = newReports.length == _pageSize;
        _isLoading = false;
      });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(
                'Device Test Reports',
                style: AppTextStyles.h1,
              ),
                Row(
                  children: [
                  AppComponents.iconButton(
                    icon: Icons.filter_list,
                    onPressed: _showFilterModal,
                    iconColor: AppColors.primaryText,
                  ),
                  AppComponents.iconButton(
                    icon: Icons.refresh,
                    onPressed: () async {
                      await _loadReports(reset: true);
                    },
                    iconColor: AppColors.primaryText,
                  ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildReportsList(),
            ),
          ],
        ),
      ),
    );
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
      return AppComponents.emptyState(
        icon: Icons.assessment_outlined,
        title: 'No reports found',
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
    Color statusColor;
    switch (report.testStatus) {
      case 'passed':
        statusColor = AppColors.successColor;
        break;
      case 'failed':
        statusColor = AppColors.errorColor;
        break;
      case 'pending':
        statusColor = AppColors.warningColor;
        break;
      case 'incomplete':
        statusColor = AppColors.tertiaryAccent;
        break;
      default:
        statusColor = AppColors.tertiaryAccent;
    }

    return AppComponents.card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          );
        },
        borderRadius: AppBorderRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.folderName,
                    style: AppTextStyles.h3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: AppBorderRadius.chip,
                  ),
                    child: Text(
                      report.testStatus?.toUpperCase() ?? 'UNKNOWN',
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (report.deviceName != null)
                Text(
                  'Device: ${report.deviceName}',
                  style: AppTextStyles.bodyMedium,
                ),
              if (report.testDate != null)
                Text(
                  'Test Date: ${report.testDate!.day}/${report.testDate!.month}/${report.testDate!.year}',
                  style: AppTextStyles.bodyMedium,
                ),
              if (report.images.isNotEmpty)
                Text(
                  'Images: ${report.images.length}',
                  style: AppTextStyles.bodyMedium,
                ),
              if (report.uploadBatch != null)
                Text(
                  'Batch: ${report.uploadBatch}',
                  style: AppTextStyles.bodySmall,
                ),
            ],
          ),
        ),
      ),
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

