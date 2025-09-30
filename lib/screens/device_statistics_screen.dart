import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../theme/service_request_components.dart';
import '../services/device_service.dart';
import '../services/service_request_service.dart';
import '../models/service_request.dart';

class DeviceStatisticsScreen extends StatefulWidget {
  final String? statisticsType;
  final String? title;
  
  const DeviceStatisticsScreen({
    super.key,
    this.statisticsType,
    this.title,
  });

  @override
  State<DeviceStatisticsScreen> createState() => _DeviceStatisticsScreenState();
}

class _DeviceStatisticsScreenState extends State<DeviceStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  int _currentDeviceIndex = 0;
  
  final DeviceService _deviceService = DeviceService();
  List<DeviceData> _devices = [];
  List<AmcPlan> _amcPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceMaps = await _deviceService.getUserDevices();
      final devices = deviceMaps.map((deviceMap) => 
          _deviceService.transformToDeviceData(deviceMap)).toList();
      
      setState(() {
        _devices = devices;
        _amcPlans = _deviceService.getAmcPlans();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        AppComponents.showErrorSnackbar(context, 'Failed to load devices: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _devices.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      AppComponents.universalHeader(
                        showBackButton: true,
                        onBackPressed: () => Navigator.pop(context),
                        deviceName: _devices.isNotEmpty ? _devices[_currentDeviceIndex].name : null,
                      ),
                      _buildDeviceCarousel(),
                      _buildTabBar(),
                      Expanded(
                        child: _buildTabContent(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/device.png',
          
            width: 120,
          ),
          const SizedBox(height: 24),
          Text(
            'No Devices Found',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No devices are registered for your organization.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildDeviceCarousel() {
    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentDeviceIndex = index;
                });
                // Reset to AMC tab (index 0) when device changes
                _tabController.animateTo(0);
              },
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildDeviceCard(_devices[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DeviceData device) {
    return AppComponents.card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Image
          Container(
            width: 120,
            height: 120,
          
            child: ClipRRect(
              child: Image.asset(
                'lib/assets/device.png',
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: AppTextStyles.h3,
                      ),
                    ),
                    // Show online status only for non-archived devices
                    if (!device.isArchived)
                      Row(
                        children: [
                          Icon(
                            Icons.wifi,
                            size: 16,
                            color: device.isOnline ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device.isOnline ? 'Online' : 'Offline',
                            style: AppTextStyles.caption.copyWith(
                              color: device.isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDeviceInfo('Device ID :', device.deviceId),
                const SizedBox(height: 4),
                _buildDeviceInfo('Device Status :', device.deviceStatus),
                const SizedBox(height: 4),
                _buildDeviceInfo('AMC Status :', device.amcStatus, device: device),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(String label, String value, {DeviceData? device}) {
    Color backgroundColor;
    Color textColor;
    
    if (label.contains('AMC Status') && device != null) {
      if (device.isAmcActive) {
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
      } else if (device.isAmcExpiringSoon) {
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
      } else {
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
      }
    } else if (value == 'Active') {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
    } else if (value == 'Inactive') {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
    } else {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
    }

    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiaryText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_devices.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentDeviceIndex == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentDeviceIndex == index 
                ? AppColors.primaryAccent 
                : AppColors.tertiaryText.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'AMC'),
          Tab(text: 'Service'),
          Tab(text: 'Details'),
        ],
        indicatorColor: AppColors.secondaryAccent,
        indicatorWeight: 3,
        labelColor: AppColors.primaryAccent,
        unselectedLabelColor: AppColors.tertiaryText,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAmcTab(),
        _buildServiceTab(),
        _buildDetailsTab(),
      ],
    );
  }

  Widget _buildAmcTab() {
    final device = _devices[_currentDeviceIndex];
    final showAmcPlans = device.isAmcExpiringSoon || !device.isAmcActive;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // AMC Status
          _buildAmcStatus(device),
          const SizedBox(height: 24),
          
          // Show AMC Plans only if AMC is expiring soon or expired
          if (showAmcPlans) ...[
            _buildAmcPlans(),
            const SizedBox(height: 24),
            
            // Add to cart button
            AppComponents.primaryButton(
              text: 'Renew AMC',
              onPressed: () {
                AppComponents.showSuccessSnackbar(context, 'AMC renewal added to cart');
              },
            ),
            const SizedBox(height: 24),
          ] else ...[
            // AMC is active - show status message
            _buildAmcActiveMessage(device),
            const SizedBox(height: 24),
          ],
          
          // Unlink Product Information
          _buildUnlinkSection(),
        ],
      ),
    );
  }

  Widget _buildAmcStatus(DeviceData device) {
    Color statusColor;
    String statusText;
    
    if (device.isAmcActive) {
      statusColor = Colors.green;
      statusText = 'AMC expires on';
    } else if (device.isAmcExpiringSoon) {
      statusColor = Colors.orange;
      statusText = 'AMC expires on';
    } else {
      statusColor = Colors.red;
      statusText = 'AMC expired on';
    }
    
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: statusColor,
              width: 4,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${device.amcDaysLeft}',
                  style: AppTextStyles.h2.copyWith(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Days',
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${device.amcExpiryDate.day} ${_getMonthName(device.amcExpiryDate.month)} ${device.amcExpiryDate.year}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmcActiveMessage(DeviceData device) {
    return AppComponents.card(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMC is Active',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your device is covered under AMC for ${device.amcDaysLeft} more days.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.tertiaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primaryAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Valid until ${device.amcExpiryDate.day} ${_getMonthName(device.amcExpiryDate.month)} ${device.amcExpiryDate.year}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmcPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMC PLANS',
          style: AppTextStyles.h3.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: _amcPlans.length,
          itemBuilder: (context, index) {
            return _buildAmcPlanCard(_amcPlans[index]);
          },
        ),
      ],
    );
  }

  Widget _buildAmcPlanCard(AmcPlan plan) {
        return Container(
          decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            plan.duration,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.price,
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlinkSection() {
    return GestureDetector(
      onTap: () {
        _showUnlinkDialog();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link_off,
            color: AppColors.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Unlink Product Information',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
          ),
        );
    }

  Widget _buildServiceTab() {
    final device = _devices[_currentDeviceIndex];
    return DeviceServicesList(deviceId: device.id);
  }

  Widget _buildDetailsTab() {
    final device = _devices[_currentDeviceIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: AppComponents.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Details',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Device Name', device.name),
            _buildDetailRow('Device ID', device.deviceId),
            _buildDetailRow('Make', device.make),
            _buildDetailRow('Model', device.model),
            _buildDetailRow('Serial Number', device.serialNumber),
            _buildDetailRow('Purchase Date', '${device.purchaseDate.day}/${device.purchaseDate.month}/${device.purchaseDate.year}'),
            _buildDetailRow('Warranty Expiry', '${device.warrantyExpiryDate.day}/${device.warrantyExpiryDate.month}/${device.warrantyExpiryDate.year}'),
            _buildDetailRow('AMC Start Date', '${device.amcStartDate.day}/${device.amcStartDate.month}/${device.amcStartDate.year}'),
            _buildDetailRow('AMC Expiry Date', '${device.amcExpiryDate.day}/${device.amcExpiryDate.month}/${device.amcExpiryDate.year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.tertiaryText,
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showUnlinkDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Unlink Device',
            style: AppTextStyles.h3,
          ),
          content: Text(
            'Are you sure you want to unlink this device? This action cannot be undone.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tertiaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppComponents.showSuccessSnackbar(context, 'Device unlinked successfully');
              },
              child: Text(
                'Unlink',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.errorColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

/// Device Services List Widget with Infinite Scroll
/// 
/// Shows service requests for a specific device with upcoming and past services sections
class DeviceServicesList extends StatefulWidget {
  final String deviceId;

  const DeviceServicesList({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceServicesList> createState() => _DeviceServicesListState();
}

class _DeviceServicesListState extends State<DeviceServicesList> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  final ScrollController _scrollController = ScrollController();
  
  List<ServiceRequest> _allServiceRequests = [];
  List<ServiceRequest> _upcomingServices = [];
  List<ServiceRequest> _pastServices = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  
  static const int _itemsPerPage = 10;
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadServiceRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreServiceRequests();
    }
  }

  Future<void> _loadServiceRequests() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentOffset = 0;
      _hasMoreData = true;
    });

    try {
      final serviceRequests = await _serviceRequestService.getDeviceServiceRequests(
        widget.deviceId,
        limit: _itemsPerPage,
        offset: _currentOffset,
      );

      if (mounted) {
        setState(() {
          _allServiceRequests = serviceRequests;
          _currentOffset = serviceRequests.length;
          _hasMoreData = serviceRequests.length == _itemsPerPage;
          _isLoading = false;
          _categorizeServices();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load service requests: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreServiceRequests() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreServiceRequests = await _serviceRequestService.getDeviceServiceRequests(
        widget.deviceId,
        limit: _itemsPerPage,
        offset: _currentOffset,
      );

      if (mounted) {
        setState(() {
          _allServiceRequests.addAll(moreServiceRequests);
          _currentOffset += moreServiceRequests.length;
          _hasMoreData = moreServiceRequests.length == _itemsPerPage;
          _isLoadingMore = false;
          _categorizeServices();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        AppComponents.showErrorSnackbar(context, 'Failed to load more services');
      }
    }
  }

  void _categorizeServices() {
    final now = DateTime.now();
    _upcomingServices = [];
    _pastServices = [];

    for (final service in _allServiceRequests) {
      if (service.status == ServiceStatus.pending ||
          (service.dateOfService != null && service.dateOfService!.isAfter(now))) {
        _upcomingServices.add(service);
      } else {
        _pastServices.add(service);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _allServiceRequests.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_allServiceRequests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadServiceRequests,
      color: AppColors.primaryAccent,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Service Request Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AppComponents.primaryButton(
                text: 'Request Service',
                onPressed: () {
                  Navigator.pushNamed(context, '/service-request');
                },
              ),
            ),
          ),

          // Upcoming Services Section
          if (_upcomingServices.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSectionHeader(
                  'Upcoming Services',
                  '${_upcomingServices.length} ${_upcomingServices.length == 1 ? 'service' : 'services'}',
                  Icons.schedule,
                  AppColors.secondaryAccent,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: ServiceRequestCard(
                      request: _upcomingServices[index],
                      margin: EdgeInsets.zero,
                    ),
                  );
                },
                childCount: _upcomingServices.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],

          // Past Services Section
          if (_pastServices.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSectionHeader(
                  'Past Services',
                  '${_pastServices.length} ${_pastServices.length == 1 ? 'service' : 'services'}',
                  Icons.history,
                  AppColors.tertiaryText,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: ServiceRequestCard(
                      request: _pastServices[index],
                      margin: EdgeInsets.zero,
                    ),
                  );
                },
                childCount: _pastServices.length,
              ),
            ),
          ],

          // Loading More Indicator
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppComponents.primaryButton(
            text: 'Request Service',
            onPressed: () {
              Navigator.pushNamed(context, '/service-request');
            },
          ),
          const SizedBox(height: 40),
          Icon(
            Icons.support_agent,
            size: 64,
            color: AppColors.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Service History',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This device has no service requests yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppComponents.primaryButton(
            text: 'Request Service',
            onPressed: () {
              Navigator.pushNamed(context, '/service-request');
            },
          ),
          const SizedBox(height: 40),
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Services',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppComponents.secondaryButton(
            text: 'Retry',
            onPressed: _loadServiceRequests,
          ),
        ],
      ),
    );
  }
}
