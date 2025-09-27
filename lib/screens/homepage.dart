import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'reports_page.dart';
import 'stats_page.dart';
import 'home_screen.dart';
import 'add_device_screen.dart';
import 'service_request_screen.dart';
import 'device_statistics_screen.dart';

// --- ImageCarousel Widget ---
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;

  final List<String> imgList = [
    'lib/assets/banner.jpg', // keep your current lib/assets path
    'lib/assets/banner.jpg',
    'lib/assets/banner.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    // Screen width
    final screenWidth = MediaQuery.of(context).size.width;
    // Dynamic height: adjust the multiplier as needed
    final carouselHeight = screenWidth * 0.5; 

    return Column(
      children: [
        SizedBox(
          width: screenWidth - 32, 
          height: carouselHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: false,
                viewportFraction: 1.0,
                height: carouselHeight,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: imgList.map((item) {
                return Image.asset(
                  item,
                  width: screenWidth,
                  height: carouselHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        width: screenWidth,
                        height: carouselHeight,
                        color: Colors.grey,
                        child: const Center(child: Text("Banner")),
                      ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // Optional: animate to page if you want
              },
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == entry.key
                      ? Colors.black
                      : Colors.grey.withOpacity(0.5),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}



class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppComponents.universalHeader(),
            ImageCarousel(),
            // Statistics cards (only for managers)
            if (authProvider.hasManagerRole) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatisticsCards(context, authProvider),
              ),
              const SizedBox(height: 24),
            ],
            
            // Instruments section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Instruments (Devices)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      _buildIconButton(
                        icon: _isSearching ? Icons.close : Icons.search,
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildIconButton(
                        icon: Icons.refresh,
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
              
            // Search bar
            if (_isSearching) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppComponents.card(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search devices...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppColors.tertiaryText),
                    ),
                    style: AppTextStyles.bodyMedium,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Device list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDevicesList(context, authProvider),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: authProvider.hasManagerRole 
          ? AppComponents.floatingActionButton(
              onAddDevice: () => _navigateToAddDevice(context),
              onServiceRequest: () => _navigateToServiceRequest(context),
            )
          : null,
    );
  }

  Widget _buildStatisticsCards(BuildContext context, AuthProvider authProvider) {
    if (authProvider.organization == null) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('0', 'Total\nDevices', 'total_devices')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('0', 'AMC\nActive', 'amc_active')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('0', 'Service\nRequest', 'service_request')),
        ],
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _authService.getDevicesForUser(authProvider.user!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Expanded(child: _buildStatCard('...', 'Total\nDevices', 'total_devices')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('...', 'AMC\nActive', 'amc_active')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('...', 'Service\nRequest', 'service_request')),
            ],
          );
        }

        final devices = snapshot.data ?? [];
        final totalDevices = devices.length;
        
        // Calculate AMC active devices
        final now = DateTime.now();
        final amcActiveDevices = devices.where((device) {
          if (device['amc_end_date'] == null) return false;
          try {
            final amcEndDate = DateTime.parse(device['amc_end_date']);
            return amcEndDate.isAfter(now);
          } catch (e) {
            return false;
          }
        }).length;

        // For service requests, we'll use 0 for now as there's no service request data structure
        final serviceRequests = 0;

        return Row(
          children: [
            Expanded(child: _buildStatCard(totalDevices.toString(), 'Total\nDevices', 'total_devices')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(amcActiveDevices.toString(), 'AMC\nActive', 'amc_active')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(serviceRequests.toString(), 'Service\nRequest', 'service_request')),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String number, String label, String statisticsType) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return GestureDetector(
      onTap: authProvider.hasManagerRole 
          ? () => _navigateToDeviceStatistics(context, statisticsType, label.replaceAll('\n', ' '))
          : null,
      child: Container(
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
            Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return AppComponents.iconButton(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.cardBackground,
      iconColor: iconColor ?? AppColors.primaryText,
      size: AppSizes.iconMedium,
    );
  }


  Widget _buildDevicesList(BuildContext context, AuthProvider authProvider) {
    if (authProvider.organization == null) {
      return AppComponents.emptyState(
        icon: Icons.business_outlined,
        title: 'No organization found',
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: authProvider.user != null 
          ? _authService.getDevicesForUser(
              authProvider.user!.id,
              searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            )
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppComponents.loadingIndicator();
        }

        if (snapshot.hasError) {
          return AppComponents.emptyState(
            icon: Icons.error_outline,
            title: 'Error loading devices',
          );
        }

        final devices = snapshot.data ?? [];

        if (devices.isEmpty) {
          return AppComponents.emptyState(
            icon: Icons.devices_outlined,
            title: 'No devices found',
            subtitle: 'No devices registered for this organization',
          );
        }

        return Column(
          children: devices.map((device) => _buildDeviceCard(context, device)).toList(),
        );
      },
    );
  }

  Widget _buildDeviceCard(BuildContext context, Map<String, dynamic> device) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isActive = device['archived'] != true;
    final now = DateTime.now();
    final amcEndDate = device['amc_end_date'] != null 
        ? DateTime.parse(device['amc_end_date']) 
        : null;
    final isAmcActive = amcEndDate != null && amcEndDate.isAfter(now);
    
    
    return GestureDetector(
      onTap: () => _navigateToReports(context, device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Top section with device info and image side by side
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                // Left side content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device title with trademark
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${device['device_name'] ?? 'Unknown Device'} ${device['model'] ?? ''}".trim(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Orange underline
                      Container(
                        width: 160,
                        height: 1,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Device ID
                      Row(
                        children: [
                          const Text(
                            'Device ID : ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            (device['id'] != null && device['id'].length >= 6)
                                ? device['id'].substring(device['id'].length - 6)
                                : (device['id'] ?? ''),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Device Status
                      Row(
                        children: [
                          const Text(
                            'Device Status : ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'Available' : 'Unavailable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // AMC Status
                      Row(
                        children: [
                          const Text(
                            'AMC Status : ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isAmcActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isAmcActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right side - Device image
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'lib/assets/device.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.devices,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              ),
            ),
            
            
            // Bottom buttons with transparent background
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToCare(context),
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadiusGeometry.directional(bottomEnd: Radius.circular(20), bottomStart: Radius.circular(20)),
                      ),
                      child: const Text(
                        'Service',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: authProvider.hasManagerRole 
                        ? () => _navigateToStats(context, device)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: authProvider.hasManagerRole 
                            ? Colors.grey[200] 
                            : Colors.grey[100],
                        borderRadius: BorderRadiusGeometry.directional(bottomEnd: Radius.circular(20), bottomStart: Radius.circular(20)),
                       
                      ),
                      child: Text(
                        'Stats',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: authProvider.hasManagerRole 
                              ? Colors.black 
                              : Colors.grey[500],
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReports(BuildContext context, Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsPage(deviceId: device['id']),
      ),
    );
  }

  void _navigateToCare(BuildContext context) {
    // Navigate to HomeScreen with Care tab selected
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(initialIndex: 1),
      ),
    );
  }

  void _navigateToStats(BuildContext context, Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsPage(device: device),
      ),
    );
  }

  void _navigateToAddDevice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDeviceScreen(),
      ),
    );
  }

  void _navigateToServiceRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceRequestScreen(),
      ),
    );
  }

  void _navigateToDeviceStatistics(BuildContext context, String statisticsType, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceStatisticsScreen(
          statisticsType: statisticsType,
          title: title,
        ),
      ),
    );
  }

}
