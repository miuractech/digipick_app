import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device_test.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.black),
                      tooltip: 'Filter',
                      onPressed: _showFilterModal,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      tooltip: 'Refresh',
                      onPressed: () async {
                        await _loadReports(reset: true);
                      },
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
    final theme = Theme.of(context);
    if (_reports.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          'No reports found',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _reports.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _reports.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(DeviceTest report) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color statusColor;
    switch (report.testStatus) {
      case 'passed':
        statusColor = Colors.green;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'incomplete':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      report.folderName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.testStatus?.toUpperCase() ?? 'UNKNOWN',
                      style: theme.textTheme.labelMedium?.copyWith(
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
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              if (report.testDate != null)
                Text(
                  'Test Date: ${report.testDate!.day}/${report.testDate!.month}/${report.testDate!.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              if (report.images.isNotEmpty)
                Text(
                  'Images: ${report.images.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              if (report.uploadBatch != null)
                Text(
                  'Batch: ${report.uploadBatch}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
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
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.background,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedDeviceId,
                decoration: InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  isDense: true,
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
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
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  isDense: true,
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
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
              Text('Date Range', style: theme.textTheme.bodyLarge),
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
                    color: theme.colorScheme.surface,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dateRange == null
                              ? 'Select date range'
                              : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
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
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

