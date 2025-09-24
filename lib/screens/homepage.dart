import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'reports_page.dart';
import 'care_page.dart';
import 'stats_page.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            // Banner section
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'lib/assets/banner.jpg',
                
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'QCVATION®\nLeading the way in\nQuality Control\nSolutions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Statistics cards
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatisticsCards(context, authProvider),
            ),
            const SizedBox(height: 24),
            
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDevicesList(context, authProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, AuthProvider authProvider) {
    if (authProvider.organization == null) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('0', 'Total\nDevices')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('0', 'AMC\nActive')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('0', 'Service\nRequest')),
        ],
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _authService.getDevicesForOrganization(authProvider.organization!['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Expanded(child: _buildStatCard('...', 'Total\nDevices')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('...', 'AMC\nActive')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('...', 'Service\nRequest')),
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
            Expanded(child: _buildStatCard(totalDevices.toString(), 'Total\nDevices')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(amcActiveDevices.toString(), 'AMC\nActive')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(serviceRequests.toString(), 'Service\nRequest')),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String number, String label) {
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
      future: authProvider.organization != null 
          ? _authService.getDevicesForOrganization(
              authProvider.organization!['id'],
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

        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return _buildDeviceCard(context, device);
          },
        );
      },
    );
  }

  Widget _buildDeviceCard(BuildContext context, Map<String, dynamic> device) {
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
                              text: "DigiPICK™ i11",
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
                    onTap: () => _navigateToStats(context, device),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadiusGeometry.directional(bottomEnd: Radius.circular(20), bottomStart: Radius.circular(20)),
                       
                      ),
                      child: const Text(
                        'Stats',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CarePage(),
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

}
