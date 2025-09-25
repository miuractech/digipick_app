import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../providers/auth_provider.dart';
import '../services/service_request_service.dart';
import '../models/service_request.dart';
import 'service_request_detail_screen.dart';

class ServiceRequestsListScreen extends StatefulWidget {
  const ServiceRequestsListScreen({super.key});

  @override
  State<ServiceRequestsListScreen> createState() => _ServiceRequestsListScreenState();
}

class _ServiceRequestsListScreenState extends State<ServiceRequestsListScreen> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  List<ServiceRequest> _serviceRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServiceRequests();
  }

  Future<void> _loadServiceRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        final requests = await _serviceRequestService.getUserServiceRequests(user.id);
        
        if (mounted) {
          setState(() {
            _serviceRequests = requests;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('User not found');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadServiceRequests,
              child: _buildBody(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/service-request');
        },
        backgroundColor: AppColors.primaryAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
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
            ElevatedButton(
              onPressed: _loadServiceRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (_serviceRequests.isEmpty)
            _buildEmptyState()
          else
            _buildServiceRequestsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVICE REQUESTS',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_serviceRequests.length} request${_serviceRequests.length != 1 ? 's' : ''} found',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.support_agent,
            size: 64,
            color: AppColors.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Service Requests',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t submitted any service requests yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/service-request');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Service Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRequestsList() {
    return Column(
      children: _serviceRequests.map((request) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildServiceRequestCard(request),
        );
      }).toList(),
    );
  }

  Widget _buildServiceRequestCard(ServiceRequest request) {
    final statusColor = _getStatusColor(request.status);
    final statusBgColor = statusColor.withOpacity(0.1);

    return GestureDetector(
      onTap: () {
        if (request.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceRequestDetailScreen(
                serviceRequestId: request.id!,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ticket number, copy button, and status
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ticket: ${request.ticketNo}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _copyTicketDetails(request),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.copy,
                    size: 14,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.status.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Device and service type
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tertiaryText,
                      ),
                    ),
                    Text(
                      request.product,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Type',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tertiaryText,
                      ),
                    ),
                    Text(
                      request.serviceType.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Service details (truncated)
          Text(
            'Details',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
          Text(
            request.serviceDetails.length > 100 
                ? '${request.serviceDetails.substring(0, 100)}...'
                : request.serviceDetails,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          
          // Assigned Engineer if available
          if (request.engineerName != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Engineer',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      Text(
                        request.engineerName!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (request.engineerPhone != null)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _callEngineer(request.engineerPhone!),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (request.engineerEmail != null)
                        GestureDetector(
                          onTap: () => _emailEngineer(request.engineerEmail!),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.email,
                              size: 16,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Dates and mode
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tertiaryText,
                      ),
                    ),
                    Text(
                      _formatDate(request.dateOfRequest),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (request.dateOfService != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferred Date',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      Text(
                        _formatDate(request.dateOfService!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              if (request.modeOfService != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      Text(
                        request.modeOfService == 'on-site' ? 'On-Site' : 'Remote',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // Attachment indicator if available
          if (request.uploadedFileUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  request.uploadedReference == 'image' ? Icons.image : Icons.attach_file,
                  size: 16,
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  request.uploadedReference == 'image' ? 'Image attached' : 'File attached',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
          ],
          
          // Engineer comments if available
          if (request.engineerComments?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Engineer Comments',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tertiaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.engineerComments!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.orange;
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.cancelled:
        return AppColors.errorColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _copyTicketDetails(ServiceRequest request) async {
    final details = '''
Ticket: ${request.ticketNo}
Device: ${request.product}
Serial Number: ${request.serialNo}
Service Type: ${request.serviceType.displayName}
Status: ${request.status.displayName}
Requested: ${_formatDate(request.dateOfRequest)}
${request.dateOfService != null ? 'Preferred Date: ${_formatDate(request.dateOfService!)}\n' : ''}
${request.engineerName != null ? 'Engineer: ${request.engineerName}\n' : ''}
${request.engineerPhone != null ? 'Engineer Phone: ${request.engineerPhone}\n' : ''}

Service Details:
${request.serviceDetails}
${request.engineerComments?.isNotEmpty == true ? '\nEngineer Comments:\n${request.engineerComments}' : ''}
''';

    await Clipboard.setData(ClipboardData(text: details));
    
    if (mounted) {
      AppComponents.showSuccessSnackbar(
        context,
        'Ticket details copied to clipboard',
      );
    }
  }

  Future<void> _callEngineer(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Unable to make phone call',
        );
      }
    }
  }

  Future<void> _emailEngineer(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Service Request Inquiry');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Unable to open email client',
        );
      }
    }
  }
}
