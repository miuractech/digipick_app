import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_request.dart';
import '../providers/auth_provider.dart';
import 'app_theme.dart';
import 'app_components.dart';

/// Service Request Utilities
class ServiceRequestUtils {
  static Widget buildStatusChip(ServiceStatus status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case ServiceStatus.pending:
        backgroundColor = AppColors.pendingBackground;
        textColor = AppColors.pendingText;
        break;
      case ServiceStatus.completed:
        backgroundColor = AppColors.completedBackground;
        textColor = AppColors.completedText;
        break;
      case ServiceStatus.cancelled:
        backgroundColor = AppColors.escalatedBackground;
        textColor = AppColors.escalatedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  static String getEngineerDisplayName(String engineerInfo) {
    // Clean up the engineer info for better display
    final cleanInfo = engineerInfo.trim();
    
    // If it's a UUID (engineer ID), format it nicely
    if (cleanInfo.contains('-') && cleanInfo.length >= 32) {
      // Looks like a UUID, return a more user-friendly format
      return 'Engineer #${cleanInfo.substring(0, 8).toUpperCase()}';
    }
    
    // If it's an email, extract the name part
    if (cleanInfo.contains('@')) {
      final namePart = cleanInfo.split('@')[0];
      // Convert snake_case or camelCase to proper name
      return _formatNameFromEmail(namePart);
    }
    
    // If it's already a proper name, capitalize it
    if (cleanInfo.contains(' ')) {
      return _capitalizeWords(cleanInfo);
    }
    
    // For single words, capitalize first letter
    return cleanInfo.isNotEmpty 
        ? '${cleanInfo[0].toUpperCase()}${cleanInfo.substring(1).toLowerCase()}'
        : 'Engineer assigned';
  }

  static String _formatNameFromEmail(String emailPrefix) {
    // Replace common separators with spaces
    String formatted = emailPrefix
        .replaceAll(RegExp(r'[._-]'), ' ')
        .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2'); // camelCase to words
    
    return _capitalizeWords(formatted);
  }

  static String _capitalizeWords(String text) {
    return text.split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

/// Service Request Card Component
/// 
/// Reusable card component for displaying service request information
class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback? onTap;
  final bool showStatus;
  final EdgeInsets? margin;

  const ServiceRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.showStatus = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showServiceRequestDetail(context),
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppBorderRadius.card,
          boxShadow: AppShadows.card,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: AppPaddings.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ticket number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ticket #${request.ticketNo}',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(request.dateOfRequest),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showStatus) ServiceRequestUtils.buildStatusChip(request.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Product and Serial Number
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.devices, size: 16, color: AppColors.primaryAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.product,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Serial: ${request.serialNo}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Service Type and Details
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.serviceType.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Service Details
              Text(
                request.serviceDetails,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer with service date and engineer
              Row(
                children: [
                  // Service Date if scheduled
                  if (request.dateOfService != null) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.event, size: 14, color: AppColors.secondaryAccent),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Service: ${DateFormat('MMM dd, yyyy').format(request.dateOfService!)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: AppColors.tertiaryText),
                          const SizedBox(width: 4),
                          Text(
                            'Service date pending',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Engineer Info
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 14, color: AppColors.tertiaryText),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          request.engineerName ?? 'No engineer assigned',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiaryText,
                            fontStyle: request.engineerName == null ? FontStyle.italic : FontStyle.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showServiceRequestDetail(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (context) => ServiceRequestDetailModal(request: request),
    );
  }
}

/// Service Request Detail Modal
/// 
/// Full-screen modal showing complete service request details and timeline
class ServiceRequestDetailModal extends StatelessWidget {
  final ServiceRequest request;

  const ServiceRequestDetailModal({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Service Request Details',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ticket Header
                    _buildTicketHeader(),
                    const SizedBox(height: 24),
                    
                    // Device Information
                    _buildDeviceInformation(),
                    const SizedBox(height: 24),
                    
                    // Service Details
                    _buildServiceDetails(),
                    const SizedBox(height: 24),
                    
                    // Engineer Details
                    _buildEngineerDetails(),
                    const SizedBox(height: 24),
                    
                    // Organization Details
                    _buildOrganizationDetails(context),
                    const SizedBox(height: 24),
                    
                    // Timeline
                    _buildTimeline(),
                    const SizedBox(height: 24),
                    
                    // Files & Attachments
                    if (request.uploadedFileUrl != null) ...[
                      _buildAttachments(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Engineer Comments
                    if (request.engineerComments != null) ...[
                      _buildEngineerComments(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Payment Details
                    if (request.paymentDetails != null) ...[
                      _buildPaymentDetails(),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket #${request.ticketNo}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primaryAccent,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${DateFormat('MMM dd, yyyy • hh:mm a').format(request.dateOfRequest)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              ServiceRequestUtils.buildStatusChip(request.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInformation() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.devices, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Device Information',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Product', request.product),
          _buildInfoRow('Serial Number', request.serialNo),
          _buildInfoRow('Service Type', request.serviceType.displayName),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Service Details',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.serviceDetails,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.5,
            ),
          ),
          if (request.modeOfService != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('Service Mode', request.modeOfService!),
          ],
          if (request.dateOfService != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              'Scheduled Service Date', 
              DateFormat('MMM dd, yyyy • hh:mm a').format(request.dateOfService!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEngineerDetails() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.engineering, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Service Engineer',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (request.engineerName != null) ...[
            _buildInfoRow('Engineer', request.engineerName!),
            if (request.engineerEmail != null)
              _buildInfoRow('Email', request.engineerEmail!),
            if (request.engineerPhone != null) ...[
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Phone',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Text(': '),
                  Expanded(
                    child: Text(
                      request.engineerPhone!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _callEngineer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Call',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_off,
                    color: AppColors.tertiaryText,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No engineer assigned',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.tertiaryText,
                      fontStyle: FontStyle.italic,
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

  Widget _buildOrganizationDetails(BuildContext context) {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Organization Details',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Organization', request.organizationName ?? 'Unknown Organization'),
          _buildInfoRow('Device', request.deviceName ?? request.product),
          _buildInfoRow('Requested By', _getRequestedByText(context)),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Timeline',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Request Created',
            DateFormat('MMM dd, yyyy • hh:mm a').format(request.dateOfRequest),
            Icons.add_circle,
            AppColors.infoColor,
            isFirst: true,
          ),
            if (request.serviceEngineer != null)
            _buildTimelineItem(
              'Engineer Assigned',
              _getEngineerDisplayName(),
              Icons.person_add,
              AppColors.primaryAccent,
            ),
          if (request.dateOfService != null)
            _buildTimelineItem(
              'Service Scheduled',
              DateFormat('MMM dd, yyyy • hh:mm a').format(request.dateOfService!),
              Icons.event,
              AppColors.secondaryAccent,
            ),
          if (request.status == ServiceStatus.completed)
            _buildTimelineItem(
              'Service Completed',
              request.updatedAt != null 
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(request.updatedAt!)
                  : 'Completed',
              Icons.check_circle,
              AppColors.successColor,
              isLast: true,
            ),
          if (request.status == ServiceStatus.cancelled)
            _buildTimelineItem(
              'Service Cancelled',
              request.updatedAt != null 
                  ? DateFormat('MMM dd, yyyy • hh:mm a').format(request.updatedAt!)
                  : 'Cancelled',
              Icons.cancel,
              AppColors.errorColor,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 12,
                color: AppColors.dividerColor,
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 16,
                color: AppColors.dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachments() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Attachments',
                style: AppTextStyles.h3,
              ),
            ],
          ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _viewAttachment(request.uploadedFileUrl!),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(request.uploadedReference),
                  color: AppColors.primaryAccent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.uploadedReference ?? 'Attachment',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to view',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new, color: AppColors.tertiaryText),
              ],
            ),
          ),
        ),
        // Image preview for image files
        if (request.uploadedReference == 'image') ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _viewAttachment(request.uploadedFileUrl!),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  request.uploadedFileUrl!,
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
                            Icons.error_outline,
                            color: AppColors.tertiaryText,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unable to load image',
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
        ],
      ),
    );
  }

  Widget _buildEngineerComments() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Engineer Comments',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.engineerComments!,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Payment Details',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.paymentDetails!,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getRequestedByText(BuildContext context) {
    // Check if current user is the same as request user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    
    if (currentUserId == request.userId) {
      return 'Requested by you';
    }
    
    // Use the requestedByName if available, otherwise use email or fallback
    return request.requestedByName ?? 
           request.requestedByEmail?.split('@')[0] ?? 
           'Unknown User';
  }

  String _getEngineerDisplayName() {
    if (request.engineerName != null) {
      return request.engineerName!;
    }
    
    if (request.serviceEngineer != null) {
      return ServiceRequestUtils.getEngineerDisplayName(request.serviceEngineer!);
    }
    
    return 'No engineer assigned';
  }

  Future<void> _callEngineer() async {
    if (request.engineerPhone != null) {
      final phoneNumber = 'tel:${request.engineerPhone}';
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      }
    }
  }

  Future<void> _viewAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

}
