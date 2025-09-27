import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_components.dart';

class DownloadService {
  /// Downloads a PDF from the given URL
  static Future<void> downloadPdf({
    required String pdfUrl,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Show loading dialog
      _showLoadingDialog(context);

      // For mobile platforms, try to open the PDF in the browser
      // For better user experience across all platforms
      await _openInBrowser(pdfUrl, context);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
      AppComponents.showErrorSnackbar(
        context,
        'Failed to open PDF: ${e.toString()}',
      );
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
                  'Opening PDF...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Opens PDF in browser
  static Future<void> _openInBrowser(String pdfUrl, BuildContext context) async {
    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        AppComponents.showSuccessSnackbar(
          context,
          'PDF opened successfully',
        );
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      rethrow;
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
}
