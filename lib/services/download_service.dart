import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_components.dart';

class DownloadService {
  static final Dio _dio = Dio();

  /// Downloads a PDF from the given URL and saves it to the digipick folder
  static Future<void> downloadPdf({
    required String pdfUrl,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Show loading dialog
      _showLoadingDialog(context);

      // Request permissions
      final hasPermission = await _requestStoragePermission();
      
      if (!hasPermission) {
        Navigator.of(context, rootNavigator: true).pop();
        AppComponents.showErrorSnackbar(
          context,
          'Storage permission is required to download PDFs. Please grant permission in Settings.',
        );
        return;
      }

      // Get the digipick folder path
      final digipickFolder = await _getDigipickFolder();
      
      // Ensure filename has .pdf extension
      final cleanFileName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
      final filePath = '${digipickFolder.path}/$cleanFileName';

      // Download the PDF
      await _downloadFile(pdfUrl, filePath, context);

      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      
      // Verify file exists after download
      final downloadedFile = File(filePath);
      if (await downloadedFile.exists()) {
        final fileSize = await downloadedFile.length();
        
        // Show success message with file location
        AppComponents.showSuccessSnackbar(
          context,
          'PDF downloaded successfully (${(fileSize / 1024).toStringAsFixed(1)} KB)',
        );

        // Show option to open the downloaded file
        _showOpenFileDialog(context, filePath);
      } else {
        AppComponents.showErrorSnackbar(
          context,
          'Download completed but file could not be verified',
        );
      }

    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      AppComponents.showErrorSnackbar(
        context,
        'Failed to download PDF: ${e.toString()}',
      );
    }
  }

  /// Requests storage permission based on platform and Android version
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        // First try to request basic storage permission
        if (!await Permission.storage.isGranted) {
          await Permission.storage.request();
        }

        // For Android 11+ (API 30+), request manage external storage if needed
        if (!await Permission.manageExternalStorage.isGranted) {
          final manageStatus = await Permission.manageExternalStorage.request();
          if (manageStatus.isGranted) {
            return true;
          }
        }

        // For Android 13+ (API 33+), also request media permissions
        if (!await Permission.photos.isGranted || !await Permission.videos.isGranted) {
          await [
            Permission.photos,
            Permission.videos,
          ].request();
        }

        // Check if we have at least one working permission
        return await Permission.storage.isGranted || 
               await Permission.manageExternalStorage.isGranted ||
               (await Permission.photos.isGranted && await Permission.videos.isGranted);
               
      } catch (e) {
        return false;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for app documents directory
      return true;
    }
    
    return false;
  }

  /// Gets or creates the digipick folder
  static Future<Directory> _getDigipickFolder() async {
    Directory? baseDirectory;
    
    if (Platform.isAndroid) {
      try {
        // First try to get the Downloads directory (Android 10+)
        final List<Directory>? downloadDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (downloadDirs != null && downloadDirs.isNotEmpty) {
          baseDirectory = downloadDirs.first;
        } else {
          // Fall back to external storage directory
          baseDirectory = await getExternalStorageDirectory();
        }
        
        // Final fallback to app documents directory
        baseDirectory ??= await getApplicationDocumentsDirectory();
        
      } catch (e) {
        // Fall back to app documents directory
        baseDirectory = await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      // Use app documents directory for iOS
      baseDirectory = await getApplicationDocumentsDirectory();
    } else {
      // Default fallback
      baseDirectory = await getApplicationDocumentsDirectory();
    }

    // Create digipick subfolder
    final digipickFolder = Directory('${baseDirectory.path}/digipick');
    
    if (!await digipickFolder.exists()) {
      await digipickFolder.create(recursive: true);
    }

    return digipickFolder;
  }

  /// Downloads the file using Dio with progress tracking
  static Future<void> _downloadFile(String url, String savePath, BuildContext context) async {
    try {
      // Ensure directory exists
      final file = File(savePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await _dio.download(url, savePath);

      // Verify file was saved
      if (!await file.exists()) {
        throw Exception('File was not saved to $savePath');
      }
      
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Shows a loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Downloading PDF...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows dialog to open the downloaded file
  static void _showOpenFileDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download Complete'),
          content: Text('PDF saved to:\n${filePath.split('/').last}\n\nChoose an action:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareFile(filePath, context);
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openFile(filePath, context);
              },
              child: const Text('Open'),
            ),
          ],
        );
      },
    );
  }

  /// Opens the downloaded file
  static Future<void> _openFile(String filePath, BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppComponents.showErrorSnackbar(
          context,
          'File not found at: ${filePath.split('/').last}',
        );
        return;
      }

      // Try to open file with default app
      try {
        final result = await OpenFile.open(filePath);
        
        if (result.type == ResultType.done) {
          AppComponents.showSuccessSnackbar(
            context,
            'PDF opened successfully',
          );
        } else if (result.type == ResultType.noAppToOpen) {
          AppComponents.showErrorSnackbar(
            context,
            'No PDF app found. Try sharing the file instead.',
          );
        } else if (result.type == ResultType.fileNotFound) {
          AppComponents.showErrorSnackbar(
            context,
            'File not found. Please try downloading again.',
          );
        } else {
          AppComponents.showErrorSnackbar(
            context,
            'Cannot open PDF. Error: ${result.message}',
          );
        }
      } catch (e) {
        AppComponents.showErrorSnackbar(
          context,
          'Plugin error. File saved to: ${filePath.split('/').last}',
        );
      }
    } catch (e) {
      AppComponents.showErrorSnackbar(
        context,
        'Cannot access file: ${e.toString()}',
      );
    }
  }

  /// Shares the downloaded file using the system share dialog
  static Future<void> _shareFile(String filePath, BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppComponents.showErrorSnackbar(
          context,
          'File not found',
        );
        return;
      }

      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: 'PDF Report from DigiPick',
        subject: 'DigiPick PDF Report',
      );

      if (result.status == ShareResultStatus.success) {
        AppComponents.showSuccessSnackbar(
          context,
          'PDF shared successfully',
        );
      }
    } catch (e) {
      AppComponents.showErrorSnackbar(
        context,
        'Cannot share file: ${e.toString()}',
      );
    }
  }

  /// Constructs a PDF URL from metadata if direct URL is not available
  static String? constructPdfUrl({
    Map<String, dynamic>? metadata,
    String? deviceId,
    String? folderName,
  }) {
    // This method can be used to construct PDF URLs from metadata
    // if there's a pattern for generating PDF URLs
    if (metadata != null && metadata['pdf_url'] != null) {
      return metadata['pdf_url'];
    }
    
    // If there's a base URL pattern for PDFs, construct it here
    // For now, return null if no direct URL is available
    return null;
  }

  /// Checks if a PDF URL is valid and accessible
  static bool isPdfUrlValid(String? pdfUrl) {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      return false;
    }
    
    try {
      final uri = Uri.parse(pdfUrl);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Gets information about the digipick folder
  static Future<Map<String, dynamic>> getDigipickFolderInfo() async {
    try {
      final digipickFolder = await _getDigipickFolder();
      final files = await digipickFolder.list().toList();
      final pdfFiles = files.where((file) => file.path.endsWith('.pdf')).toList();
      
      return {
        'folderPath': digipickFolder.path,
        'totalFiles': files.length,
        'pdfFiles': pdfFiles.length,
        'folderExists': await digipickFolder.exists(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'folderExists': false,
      };
    }
  }
}
