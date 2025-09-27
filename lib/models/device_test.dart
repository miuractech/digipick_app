class DeviceTest {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String folderName;
  final String? pdfUrl;
  final List<String> images;
  final String? deviceId;
  final String? deviceName;
  final String? deviceType;
  final Map<String, dynamic>? testResults;
  final DateTime? testDate;
  final String? testStatus;
  final String? uploadBatch;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? data;
  final String? dataType;

  DeviceTest({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.folderName,
    this.pdfUrl,
    required this.images,
    this.deviceId,
    this.deviceName,
    this.deviceType,
    this.testResults,
    this.testDate,
    this.testStatus,
    this.uploadBatch,
    this.notes,
    this.metadata,
    this.data,
    this.dataType,
  });

  factory DeviceTest.fromJson(Map<String, dynamic> json) {
    return DeviceTest(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      folderName: json['folder_name'],
      pdfUrl: json['pdf_url'],
      images: List<String>.from(json['images'] ?? []),
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      deviceType: json['device_type'],
      testResults: json['test_results'],
      testDate: json['test_date'] != null ? DateTime.parse(json['test_date']) : null,
      testStatus: json['test_status'],
      uploadBatch: json['upload_batch'],
      notes: json['notes'],
      metadata: json['metadata'],
      data: json['data'],
      dataType: json['data_type'],
    );
  }

  String get statusColor {
    switch (testStatus) {
      case 'passed':
        return 'green';
      case 'failed':
        return 'red';
      case 'pending':
        return 'orange';
      case 'incomplete':
        return 'grey';
      default:
        return 'grey';
    }
  }
}
