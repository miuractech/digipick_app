import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../theme/service_request_components.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CarePage extends StatefulWidget {
  const CarePage({super.key});

  @override
  State<CarePage> createState() => _CarePageState();
}

class _CarePageState extends State<CarePage> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ServiceRequest> _allServiceRequests = [];
  List<ServiceRequest> _filteredServiceRequests = [];
  List<ServiceRequest> _upcomingServices = [];
  List<ServiceRequest> _pastServices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  // Filter options
  ServiceType? _selectedServiceType;
  ServiceStatus? _selectedStatus;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadServiceRequests();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    // Debounce the search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == _searchController.text) {
        _applyFilters();
      }
    });
  }

  Future<void> _loadServiceRequests() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      String? organizationId;
      
      // Try to get organization ID from different sources
      if (authProvider.user?.userMetadata?['organization_id'] != null) {
        organizationId = authProvider.user!.userMetadata!['organization_id'];
      } else if (authProvider.organization != null) {
        organizationId = authProvider.organization!['id'];
      }
      
      if (organizationId != null) {
        final requests = await _serviceRequestService.searchServiceRequests(
          organizationId: organizationId,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          serviceType: _selectedServiceType,
          status: _selectedStatus,
          fromDate: _dateRange?.start,
          toDate: _dateRange?.end,
        );
        
        setState(() {
          _allServiceRequests = requests;
          _filteredServiceRequests = requests;
          _organizeServiceRequests(requests);
        });
      } else {
        print('No organization ID found');
        if (mounted) {
          AppComponents.showErrorSnackbar(context, 'Organization not found');
        }
      }
    } catch (e) {
      print('Error loading service requests: $e');
      if (mounted) {
        AppComponents.showErrorSnackbar(context, 'Failed to load service requests');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    // Reload service requests with current filters
    _loadServiceRequests();
  }

  void _organizeServiceRequests(List<ServiceRequest> requests) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _upcomingServices = [];
    _pastServices = [];

    for (final request in requests) {
      // Determine if service is upcoming or past based on service date or status
      bool isUpcoming = false;

      if (request.status == ServiceStatus.pending) {
        // Pending requests are upcoming
        isUpcoming = true;
      } else if (request.status == ServiceStatus.completed || request.status == ServiceStatus.cancelled) {
        // Completed or cancelled requests are past
        isUpcoming = false;
      } else if (request.dateOfService != null) {
        // Check if service date is in the future
        final serviceDate = DateTime(
          request.dateOfService!.year,
          request.dateOfService!.month,
          request.dateOfService!.day,
        );
        isUpcoming = serviceDate.isAfter(today) || serviceDate.isAtSameMomentAs(today);
      } else {
        // No service date and pending - consider upcoming
        isUpcoming = request.status == ServiceStatus.pending;
      }

      if (isUpcoming) {
        _upcomingServices.add(request);
      } else {
        _pastServices.add(request);
      }
    }

    // Sort upcoming by service date (earliest first), then by request date
    _upcomingServices.sort((a, b) {
      if (a.dateOfService != null && b.dateOfService != null) {
        return a.dateOfService!.compareTo(b.dateOfService!);
      } else if (a.dateOfService != null) {
        return -1; // a has service date, prioritize it
      } else if (b.dateOfService != null) {
        return 1; // b has service date, prioritize it
      } else {
        return a.dateOfRequest.compareTo(b.dateOfRequest);
      }
    });

    // Sort past by completion date (most recent first)
    _pastServices.sort((a, b) {
      final aDate = a.dateOfService ?? a.updatedAt ?? a.dateOfRequest;
      final bDate = b.dateOfService ?? b.updatedAt ?? b.dateOfRequest;
      return bDate.compareTo(aDate);
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedServiceType = null;
      _selectedStatus = null;
      _dateRange = null;
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _showFilterModal() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => ServiceRequestFilterModal(
        selectedServiceType: _selectedServiceType,
        selectedStatus: _selectedStatus,
        dateRange: _dateRange,
        onApply: (serviceType, status, dateRange) {
          setState(() {
            _selectedServiceType = serviceType;
            _selectedStatus = status;
            _dateRange = dateRange;
          });
          _applyFilters();
          Navigator.of(context).pop();
        },
        onClear: () {
          _clearFilters();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppComponents.universalHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  Text(
                    'Service History',
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  
                  // Results Header
                  _buildResultsHeader(),
                  const SizedBox(height: 16),
                  
                  // Service Requests List
                  Expanded(
                    child: _buildServiceRequestsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.input,
        boxShadow: AppShadows.card,
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search by ticket, product, serial number, or description...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiaryText,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.tertiaryText),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.tertiaryText),
                  onPressed: () => _searchController.clear(),
                ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: (_selectedServiceType != null || _selectedStatus != null || _dateRange != null)
                      ? AppColors.primaryAccent
                      : AppColors.tertiaryText,
                ),
                onPressed: _showFilterModal,
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }


  Widget _buildResultsHeader() {
    int totalCount = _allServiceRequests.length;
    int upcomingCount = _upcomingServices.length;
    int pastCount = _pastServices.length;
    bool hasFilters = _searchQuery.isNotEmpty || 
                     _selectedServiceType != null || 
                     _selectedStatus != null || 
                     _dateRange != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasFilters 
                    ? 'Filtered Results: $totalCount requests'
                    : '$totalCount total service requests',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalCount > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '$upcomingCount upcoming • $pastCount completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.tertiaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildServiceRequestsList() {
    if (_isLoading) {
      return AppComponents.loadingIndicator(message: 'Loading service requests...');
    }

    if (_filteredServiceRequests.isEmpty) {
      if (_allServiceRequests.isEmpty) {
        return AppComponents.emptyState(
          icon: Icons.build_outlined,
          title: 'No Service Requests',
          subtitle: 'You haven\'t made any service requests yet.\nCreate your first service request to get started.',
        );
      } else {
        return AppComponents.emptyState(
          icon: Icons.search_off,
          title: 'No Results Found',
          subtitle: 'Try adjusting your search or filter criteria to find what you\'re looking for.',
        );
      }
    }

    return RefreshIndicator(
      onRefresh: _loadServiceRequests,
      color: AppColors.primaryAccent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Upcoming Services Section
          if (_upcomingServices.isNotEmpty) ...[
            _buildSectionHeader(
              'Upcoming Services',
              '${_upcomingServices.length} ${_upcomingServices.length == 1 ? 'request' : 'requests'}',
              Icons.schedule,
              AppColors.secondaryAccent,
            ),
            const SizedBox(height: 12),
            ..._upcomingServices.map((request) => ServiceRequestCard(
              request: request,
              margin: const EdgeInsets.only(bottom: 12),
            )),
            const SizedBox(height: 24),
          ],
          
          // Past Services Section
          if (_pastServices.isNotEmpty) ...[
            _buildSectionHeader(
              'Past Services',
              '${_pastServices.length} ${_pastServices.length == 1 ? 'request' : 'requests'}',
              Icons.history,
              AppColors.tertiaryText,
            ),
            const SizedBox(height: 12),
            ..._pastServices.map((request) => ServiceRequestCard(
              request: request,
              margin: const EdgeInsets.only(bottom: 12),
            )),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class ServiceRequestFilterModal extends StatefulWidget {
  final ServiceType? selectedServiceType;
  final ServiceStatus? selectedStatus;
  final DateTimeRange? dateRange;
  final void Function(ServiceType?, ServiceStatus?, DateTimeRange?) onApply;
  final VoidCallback onClear;

  const ServiceRequestFilterModal({
    super.key,
    required this.selectedServiceType,
    required this.selectedStatus,
    required this.dateRange,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<ServiceRequestFilterModal> createState() => _ServiceRequestFilterModalState();
}

class _ServiceRequestFilterModalState extends State<ServiceRequestFilterModal> {
  ServiceType? _selectedServiceType;
  ServiceStatus? _selectedStatus;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.selectedServiceType;
    _selectedStatus = widget.selectedStatus;
    _dateRange = widget.dateRange;
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
              // Handle bar
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
              
              // Title
              Text('Filters', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              
              // Service Type Filter
              Text('Service Type', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<ServiceType>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.input,
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                hint: Text('All Service Types', style: AppTextStyles.bodyMedium),
                items: [
                  const DropdownMenuItem<ServiceType>(
                    value: null,
                    child: Text('All Service Types'),
                  ),
                  ...ServiceType.values.map((type) => DropdownMenuItem<ServiceType>(
                    value: type,
                    child: Text(type.displayName),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedServiceType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Status Filter
              Text('Status', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<ServiceStatus>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.input,
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                hint: Text('All Statuses', style: AppTextStyles.bodyMedium),
                items: [
                  const DropdownMenuItem<ServiceStatus>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...ServiceStatus.values.map((status) => DropdownMenuItem<ServiceStatus>(
                    value: status,
                    child: Text(status.displayName),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Date Range Filter
              Text('Date Range', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: _dateRange,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primaryAccent,
                          ),
                        ),
                        child: child!,
                      );
                    },
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
                              : '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _dateRange != null ? AppColors.primaryText : AppColors.tertiaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _selectedServiceType,
                          _selectedStatus,
                          _dateRange,
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
