import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';

class ServiceRequestDetailScreen extends StatefulWidget {
  final String serviceRequestId;

  const ServiceRequestDetailScreen({
    super.key,
    required this.serviceRequestId,
  });

  @override
  State<ServiceRequestDetailScreen> createState() => _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState extends State<ServiceRequestDetailScreen> {
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  ServiceRequest? _serviceRequest;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServiceRequest();
  }

  Future<void> _loadServiceRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = await _serviceRequestService.getServiceRequestById(widget.serviceRequestId);
      
      if (request == null) {
        throw Exception('Service request not found');
      }
      
      if (mounted) {
        setState(() {
          _serviceRequest = request;
          _isLoading = false;
        });

        // Show a warning if engineer details couldn't be fetched
        if (request.serviceEngineer != null && 
            request.engineerName == null && 
            request.engineerPhone == null && 
            request.engineerEmail == null) {
          _showEngineerDetailsWarning();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'Service request not found. The ticket may have been deleted or the ID is incorrect.';
    } else if (errorStr.contains('unauthorized') || errorStr.contains('403')) {
      return 'You don\'t have permission to view this service request.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Failed to load service request. Please try again later.';
    }
  }

  void _showEngineerDetailsWarning() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Engineer is assigned but contact details are being updated. Please try refreshing in a moment.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
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
            actions: [
              IconButton(
                onPressed: _loadServiceRequest,
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.primaryAccent,
                ),
                tooltip: 'Refresh',
              ),
            ],
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
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
              onPressed: _loadServiceRequest,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_serviceRequest == null) {
      return Center(
        child: Text(
          'Service request not found',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiaryText,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildStatusSection(),
          const SizedBox(height: 12),
          _buildDeviceSection(),
          const SizedBox(height: 12),
          _buildServiceDetailsSection(),
          const SizedBox(height: 12),
          _buildDatesSection(),
          if (_serviceRequest!.engineerName != null) ...[
            const SizedBox(height: 12),
            _buildEngineerSection(),
          ],
          if (_serviceRequest!.engineerComments?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _buildEngineerCommentsSection(),
          ],
          if (_serviceRequest!.uploadedFileUrl != null) ...[
            const SizedBox(height: 12),
            _buildAttachmentSection(),
          ],
          const SizedBox(height: 12),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ticket: ${_serviceRequest!.ticketNo}',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copyTicketDetails,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Service Request Details',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    final statusColor = _getStatusColor(_serviceRequest!.status);
    final statusBgColor = statusColor.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _serviceRequest!.status.displayName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Status',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Information',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Device', _serviceRequest!.product),
          const SizedBox(height: 4),
          _buildInfoRow('Serial Number', _serviceRequest!.serialNo),
          const SizedBox(height: 4),
          _buildInfoRow('Service Type', _serviceRequest!.serviceType.displayName),
          if (_serviceRequest!.modeOfService != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Service Mode', _serviceRequest!.modeOfService == 'on-site' ? 'On-Site' : 'Remote'),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _serviceRequest!.serviceDetails,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Requested', _formatDate(_serviceRequest!.dateOfRequest)),
          if (_serviceRequest!.dateOfService != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Preferred Date', _formatDate(_serviceRequest!.dateOfService!)),
          ],
          if (_serviceRequest!.createdAt != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Created', _formatDateTime(_serviceRequest!.createdAt!)),
          ],
          if (_serviceRequest!.updatedAt != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Last Updated', _formatDateTime(_serviceRequest!.updatedAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildEngineerSection() {
    final bool hasEngineer = _serviceRequest!.engineerName != null;
    final bool hasPhone = _serviceRequest!.engineerPhone != null;
    final bool hasEmail = _serviceRequest!.engineerEmail != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasEngineer 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  hasEngineer ? Icons.person : Icons.person_outline,
                  size: 20,
                  color: hasEngineer ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasEngineer ? 'Assigned Engineer' : 'Engineer Assignment',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasEngineer && hasPhone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_enabled,
                        size: 12,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!hasEngineer) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No engineer assigned yet. Your request is being processed.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Engineer details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8FFFE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Name', _serviceRequest!.engineerName!),
                  if (hasEmail) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Email', _serviceRequest!.engineerEmail!),
                  ],
                  if (hasPhone) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Phone', _serviceRequest!.engineerPhone!),
                  ],
                ],
              ),
            ),
            
            if (hasPhone || hasEmail) ...[
              const SizedBox(height: 16),
              Text(
                'Contact Engineer',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tertiaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (hasPhone) ...[
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.phone,
                        label: 'Call',
                        color: Colors.green,
                        onTap: () => _callEngineer(_serviceRequest!.engineerPhone!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.message,
                        label: 'WhatsApp',
                        color: Color(0xFF25D366),
                        onTap: () => _launchWhatsApp(_serviceRequest!.engineerPhone!),
                      ),
                    ),
                    if (hasEmail) const SizedBox(width: 8),
                  ],
                  if (hasEmail)
                    Expanded(
                      child: _buildContactButton(
                        icon: Icons.email,
                        label: 'Email',
                        color: AppColors.primaryAccent,
                        onTap: () => _emailEngineer(_serviceRequest!.engineerEmail!),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEngineerCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engineer Comments',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _serviceRequest!.engineerComments!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachments',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildAttachmentItem(),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem() {
    final isImage = _serviceRequest!.uploadedReference == 'image';
    final isVideo = _serviceRequest!.uploadedReference == 'video' || 
                   _serviceRequest!.uploadedFileUrl!.contains('.mp4') ||
                   _serviceRequest!.uploadedFileUrl!.contains('.mov') ||
                   _serviceRequest!.uploadedFileUrl!.contains('.avi');
    
    String attachmentType = 'File';
    IconData attachmentIcon = Icons.attach_file;
    
    if (isImage) {
      attachmentType = 'Image';
      attachmentIcon = Icons.image;
    } else if (isVideo) {
      attachmentType = 'Video';
      attachmentIcon = Icons.videocam;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _viewAttachment(_serviceRequest!.uploadedFileUrl!),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  attachmentIcon,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachmentType,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to view attachment',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  color: AppColors.tertiaryText,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (isImage) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _viewAttachment(_serviceRequest!.uploadedFileUrl!),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  _serviceRequest!.uploadedFileUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 32,
                            color: AppColors.tertiaryText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
        if (isVideo) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _viewAttachment(_serviceRequest!.uploadedFileUrl!),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to play video',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tertiaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.quick_contacts_dialer,
                  size: 20,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Primary Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyTicketDetails,
                  icon: Icon(Icons.content_copy, size: 18),
                  label: Text('Copy All Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareTicketDetails(),
                  icon: Icon(Icons.share, size: 18),
                  label: Text('Share Ticket'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    side: BorderSide(color: AppColors.primaryAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyBasicDetails(),
                  icon: Icon(Icons.copy, size: 16),
                  label: Text('Copy Basic Info'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.tertiaryText,
                    side: BorderSide(color: AppColors.dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchPhone('+911234567890'), // Replace with actual support number
                  icon: Icon(Icons.support_agent, size: 16),
                  label: Text('Call Support'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _copyTicketDetails() async {
    final StringBuffer details = StringBuffer();
    
    // Header
    details.writeln('📋 SERVICE REQUEST DETAILS');
    details.writeln('=' * 30);
    
    // Basic Information
    details.writeln('🎫 Ticket Number: ${_serviceRequest!.ticketNo}');
    details.writeln('📱 Device: ${_serviceRequest!.product}');
    details.writeln('🔢 Serial Number: ${_serviceRequest!.serialNo}');
    details.writeln('🔧 Service Type: ${_serviceRequest!.serviceType.displayName}');
    if (_serviceRequest!.modeOfService != null) {
      details.writeln('📍 Service Mode: ${_serviceRequest!.modeOfService == 'on-site' ? 'On-Site' : 'Remote'}');
    }
    details.writeln('⚡ Status: ${_serviceRequest!.status.displayName}');
    details.writeln();
    
    // Timeline
    details.writeln('📅 TIMELINE:');
    details.writeln('• Requested: ${_formatDate(_serviceRequest!.dateOfRequest)}');
    if (_serviceRequest!.dateOfService != null) {
      details.writeln('• Preferred Date: ${_formatDate(_serviceRequest!.dateOfService!)}');
    }
    if (_serviceRequest!.createdAt != null) {
      details.writeln('• Created: ${_formatDateTime(_serviceRequest!.createdAt!)}');
    }
    if (_serviceRequest!.updatedAt != null) {
      details.writeln('• Last Updated: ${_formatDateTime(_serviceRequest!.updatedAt!)}');
    }
    details.writeln();
    
    // Engineer Information
    if (_serviceRequest!.engineerName != null) {
      details.writeln('👨‍🔧 ASSIGNED ENGINEER:');
      details.writeln('• Name: ${_serviceRequest!.engineerName}');
      if (_serviceRequest!.engineerPhone != null) {
        details.writeln('• Phone: ${_serviceRequest!.engineerPhone}');
      }
      if (_serviceRequest!.engineerEmail != null) {
        details.writeln('• Email: ${_serviceRequest!.engineerEmail}');
      }
      details.writeln();
    }
    
    // Service Details
    details.writeln('📝 SERVICE DETAILS:');
    details.writeln(_serviceRequest!.serviceDetails);
    details.writeln();
    
    // Engineer Comments
    if (_serviceRequest!.engineerComments?.isNotEmpty == true) {
      details.writeln('💬 ENGINEER COMMENTS:');
      details.writeln(_serviceRequest!.engineerComments);
      details.writeln();
    }
    
    // Organization
    if (_serviceRequest!.organizationName != null) {
      details.writeln('🏢 Organization: ${_serviceRequest!.organizationName}');
    }
    
    // Payment Details
    if (_serviceRequest!.paymentDetails != null) {
      details.writeln('💳 Payment: ${_serviceRequest!.paymentDetails}');
    }
    
    // Footer
    details.writeln();
    details.writeln('=' * 30);
    details.writeln('Generated on ${_formatDateTime(DateTime.now())}');
    details.writeln('Paramount Healthcare Solutions');

    await Clipboard.setData(ClipboardData(text: details.toString()));
    
    if (mounted) {
      AppComponents.showSuccessSnackbar(
        context,
        'Complete ticket details copied to clipboard!',
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
    final uri = Uri.parse('mailto:$email?subject=Service Request ${_serviceRequest!.ticketNo}');
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

  Future<void> _launchWhatsApp(String phoneNumber) async {
    // Remove any non-numeric characters except +
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure the number starts with country code
    if (!cleanNumber.startsWith('+')) {
      // If the number doesn't start with +, assume it's an Indian number and add +91
      if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
        cleanNumber = '+$cleanNumber';
      } else if (cleanNumber.length == 10) {
        cleanNumber = '+91$cleanNumber';
      } else {
        cleanNumber = '+$cleanNumber';
      }
    }
    
    final message = Uri.encodeComponent(
      'Hello, I am contacting you regarding service request ${_serviceRequest!.ticketNo} for ${_serviceRequest!.product} (Serial: ${_serviceRequest!.serialNo}).'
    );
    
    final uri = Uri.parse('https://wa.me/$cleanNumber?text=$message');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Unable to open WhatsApp. Please ensure WhatsApp is installed.',
        );
      }
    }
  }

  Future<void> _copyBasicDetails() async {
    final basicDetails = '''
Ticket: ${_serviceRequest!.ticketNo}
Device: ${_serviceRequest!.product}
Serial: ${_serviceRequest!.serialNo}
Service: ${_serviceRequest!.serviceType.displayName}
Status: ${_serviceRequest!.status.displayName}
${_serviceRequest!.engineerName != null ? 'Engineer: ${_serviceRequest!.engineerName}' : ''}
${_serviceRequest!.engineerPhone != null ? 'Phone: ${_serviceRequest!.engineerPhone}' : ''}
''';

    await Clipboard.setData(ClipboardData(text: basicDetails.trim()));
    
    if (mounted) {
      AppComponents.showSuccessSnackbar(
        context,
        'Basic details copied to clipboard',
      );
    }
  }

  Future<void> _shareTicketDetails() async {
    try {
      final StringBuffer shareText = StringBuffer();
      
      shareText.writeln('Service Request Details');
      shareText.writeln('');
      shareText.writeln('Ticket: ${_serviceRequest!.ticketNo}');
      shareText.writeln('Device: ${_serviceRequest!.product}');
      shareText.writeln('Serial: ${_serviceRequest!.serialNo}');
      shareText.writeln('Service: ${_serviceRequest!.serviceType.displayName}');
      shareText.writeln('Status: ${_serviceRequest!.status.displayName}');
      shareText.writeln('Requested: ${_formatDate(_serviceRequest!.dateOfRequest)}');
      
      if (_serviceRequest!.engineerName != null) {
        shareText.writeln('');
        shareText.writeln('Engineer: ${_serviceRequest!.engineerName}');
        if (_serviceRequest!.engineerPhone != null) {
          shareText.writeln('Phone: ${_serviceRequest!.engineerPhone}');
        }
      }
      
      shareText.writeln('');
      shareText.writeln('Details: ${_serviceRequest!.serviceDetails}');
      
      // Create a mailto URL for sharing via email
      final subject = Uri.encodeComponent('Service Request ${_serviceRequest!.ticketNo}');
      final body = Uri.encodeComponent(shareText.toString());
      final mailtoUri = Uri.parse('mailto:?subject=$subject&body=$body');
      
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        // Fallback to copying to clipboard if email client is not available
        await Clipboard.setData(ClipboardData(text: shareText.toString()));
        if (mounted) {
          AppComponents.showSuccessSnackbar(
            context,
            'Details copied to clipboard for sharing',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Unable to share ticket details',
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
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

  Future<void> _viewAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Unable to open attachment',
        );
      }
    }
  }
}
