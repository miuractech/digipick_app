/// Service Request Model
/// 
/// This model represents a service request in the application and matches
/// the database schema defined in sql/service_requests.sql

class ServiceRequest {
  final String? id;
  final String ticketNo;
  final String product;
  final String serialNo;
  final ServiceType serviceType;
  final String serviceDetails;
  final String organizationId;
  final String deviceId;
  final String userId;
  final DateTime dateOfRequest;
  final DateTime? dateOfService;
  final String? uploadedReference;
  final String? uploadedFileUrl;
  final String? modeOfService;
  final String? serviceEngineer;
  final String? engineerComments;
  final ServiceStatus status;
  final String? paymentDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Additional display fields (populated from joins)
  final String? organizationName;
  final String? deviceName;
  final String? requestedByName;
  final String? requestedByEmail;
  final String? engineerName;
  final String? engineerEmail;
  final String? engineerPhone;

  ServiceRequest({
    this.id,
    required this.ticketNo,
    required this.product,
    required this.serialNo,
    required this.serviceType,
    required this.serviceDetails,
    required this.organizationId,
    required this.deviceId,
    required this.userId,
    required this.dateOfRequest,
    this.dateOfService,
    this.uploadedReference,
    this.uploadedFileUrl,
    this.modeOfService,
    this.serviceEngineer,
    this.engineerComments,
    this.status = ServiceStatus.pending,
    this.paymentDetails,
    this.createdAt,
    this.updatedAt,
    
    // Additional display fields
    this.organizationName,
    this.deviceName,
    this.requestedByName,
    this.requestedByEmail,
    this.engineerName,
    this.engineerEmail,
    this.engineerPhone,
  });

  /// Create ServiceRequest from JSON/Map (from database)
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      ticketNo: json['ticket_no'] ?? '',
      product: json['product'] ?? '',
      serialNo: json['serial_no'] ?? '',
      serviceType: ServiceType.fromString(json['service_type'] ?? 'service'),
      serviceDetails: json['service_details'] ?? '',
      organizationId: json['organization_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      userId: json['user_id'] ?? '',
      dateOfRequest: json['date_of_request'] != null 
          ? DateTime.parse(json['date_of_request']) 
          : DateTime.now(),
      dateOfService: json['date_of_service'] != null 
          ? DateTime.parse(json['date_of_service']) 
          : null,
      uploadedReference: json['uploaded_reference'],
      uploadedFileUrl: json['uploaded_file_url'],
      modeOfService: json['mode_of_service'],
      serviceEngineer: json['service_engineer'],
      engineerComments: json['engineer_comments'],
      status: ServiceStatus.fromString(json['status'] ?? 'pending'),
      paymentDetails: json['payment_details'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      
      // Additional display fields from joins
      organizationName: json['company_details']?['name'],
      deviceName: json['devices']?['device_name'],
      requestedByName: json['user_profiles']?['full_name'] ?? json['auth_users']?['email']?.split('@')[0],
      requestedByEmail: json['user_profiles']?['email'] ?? json['auth_users']?['email'],
      engineerName: json['service_engineers']?['name'],
      engineerEmail: json['service_engineers']?['email'],
      engineerPhone: json['service_engineers']?['contact_number'],
    );
  }

  /// Convert ServiceRequest to JSON/Map (for database)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ticket_no': ticketNo,
      'product': product,
      'serial_no': serialNo,
      'service_type': serviceType.value,
      'service_details': serviceDetails,
      'organization_id': organizationId,
      'device_id': deviceId,
      'user_id': userId,
      'date_of_request': dateOfRequest.toIso8601String(),
      if (dateOfService != null) 'date_of_service': dateOfService!.toIso8601String(),
      if (uploadedReference != null) 'uploaded_reference': uploadedReference,
      if (uploadedFileUrl != null) 'uploaded_file_url': uploadedFileUrl,
      if (modeOfService != null) 'mode_of_service': modeOfService,
      if (serviceEngineer != null) 'service_engineer': serviceEngineer,
      if (engineerComments != null) 'engineer_comments': engineerComments,
      'status': status.value,
      if (paymentDetails != null) 'payment_details': paymentDetails,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy of ServiceRequest with updated fields
  ServiceRequest copyWith({
    String? id,
    String? ticketNo,
    String? product,
    String? serialNo,
    ServiceType? serviceType,
    String? serviceDetails,
    String? organizationId,
    String? deviceId,
    String? userId,
    DateTime? dateOfRequest,
    DateTime? dateOfService,
    String? uploadedReference,
    String? uploadedFileUrl,
    String? modeOfService,
    String? serviceEngineer,
    String? engineerComments,
    ServiceStatus? status,
    String? paymentDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? organizationName,
    String? deviceName,
    String? requestedByName,
    String? requestedByEmail,
    String? engineerName,
    String? engineerEmail,
    String? engineerPhone,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      ticketNo: ticketNo ?? this.ticketNo,
      product: product ?? this.product,
      serialNo: serialNo ?? this.serialNo,
      serviceType: serviceType ?? this.serviceType,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      organizationId: organizationId ?? this.organizationId,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      dateOfRequest: dateOfRequest ?? this.dateOfRequest,
      dateOfService: dateOfService ?? this.dateOfService,
      uploadedReference: uploadedReference ?? this.uploadedReference,
      uploadedFileUrl: uploadedFileUrl ?? this.uploadedFileUrl,
      modeOfService: modeOfService ?? this.modeOfService,
      serviceEngineer: serviceEngineer ?? this.serviceEngineer,
      engineerComments: engineerComments ?? this.engineerComments,
      status: status ?? this.status,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      organizationName: organizationName ?? this.organizationName,
      deviceName: deviceName ?? this.deviceName,
      requestedByName: requestedByName ?? this.requestedByName,
      requestedByEmail: requestedByEmail ?? this.requestedByEmail,
      engineerName: engineerName ?? this.engineerName,
      engineerEmail: engineerEmail ?? this.engineerEmail,
      engineerPhone: engineerPhone ?? this.engineerPhone,
    );
  }

  @override
  String toString() {
    return 'ServiceRequest(id: $id, ticketNo: $ticketNo, product: $product, status: ${status.value})';
  }
}

/// Service Type Enum
enum ServiceType {
  demoInstallation('demo_installation'),
  repair('repair'),
  service('service'),
  calibration('calibration');

  const ServiceType(this.value);

  final String value;

  static ServiceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'demo_installation':
        return ServiceType.demoInstallation;
      case 'repair':
        return ServiceType.repair;
      case 'service':
        return ServiceType.service;
      case 'calibration':
        return ServiceType.calibration;
      default:
        return ServiceType.service;
    }
  }

  String get displayName {
    switch (this) {
      case ServiceType.demoInstallation:
        return 'Demo / Installation';
      case ServiceType.repair:
        return 'Repair';
      case ServiceType.service:
        return 'Servicing';
      case ServiceType.calibration:
        return 'Calibration';
    }
  }
}

/// Service Status Enum
enum ServiceStatus {
  pending('pending'),
  completed('completed'),
  cancelled('cancelled');

  const ServiceStatus(this.value);

  final String value;

  static ServiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ServiceStatus.pending;
      case 'completed':
        return ServiceStatus.completed;
      case 'cancelled':
        return ServiceStatus.cancelled;
      default:
        return ServiceStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ServiceStatus.pending:
        return 'Pending';
      case ServiceStatus.completed:
        return 'Completed';
      case ServiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Service Mode Enum
enum ServiceMode {
  onSite('on-site'),
  remote('remote');

  const ServiceMode(this.value);

  final String value;

  static ServiceMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'on-site':
        return ServiceMode.onSite;
      case 'remote':
        return ServiceMode.remote;
      default:
        return ServiceMode.onSite;
    }
  }

  String get displayName {
    switch (this) {
      case ServiceMode.onSite:
        return 'On-Site';
      case ServiceMode.remote:
        return 'Remote';
    }
  }
}
