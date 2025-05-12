import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart'; // For acerPrimaryColor

// Debug function to log assets
Future<void> _debugListAssets() async {
  // For debugging purposes, print asset manifest
  debugPrint('Debugging assets...');
  try {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    debugPrint('Asset manifest: $manifestContent');
  } catch (e) {
    debugPrint('Failed to load manifest: $e');
  }
}

class InvoiceViewer extends StatelessWidget {
  final String pdfAssetPath;
  final String invoiceNumber;

  const InvoiceViewer({
    Key? key,
    required this.pdfAssetPath,
    required this.invoiceNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #$invoiceNumber'),
        backgroundColor: acerPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice sharing would be implemented here'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Invoice #$invoiceNumber',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'PDF is ready to view',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.visibility),
              label: const Text('View Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _openPdf(context),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _downloadPdf(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Opening invoice..."),
                ],
              ),
            ),
          );
        },
      );

      // Debug step - log the asset path
      debugPrint('Attempting to load PDF from: $pdfAssetPath');
      await _debugListAssets();

      // Fix asset path - make sure format is correct
      // The correct path should not have a colon and should use correct slashes
      String correctedPath = pdfAssetPath;
      if (correctedPath.contains(':')) {
        correctedPath = correctedPath.replaceAll('assets:', 'assets');
      }
      if (correctedPath.contains('/Invoice/')) {
        correctedPath = correctedPath.replaceAll('/Invoice/', '/invoice/');
      }

      debugPrint('Corrected path: $correctedPath');

      // Create a temporary file to store the asset content
      final ByteData data = await rootBundle.load(correctedPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String filePath = '$tempPath/invoice_${invoiceNumber}.pdf';

      // Write to temporary file
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Open the file
      final Uri uri = Uri.file(filePath);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch PDF viewer';
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      debugPrint('Error opening PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open the PDF: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      // Debug step - log the asset path
      debugPrint('Attempting to download PDF from: $pdfAssetPath');

      // Fix asset path - make sure format is correct
      String correctedPath = pdfAssetPath;
      if (correctedPath.contains(':')) {
        correctedPath = correctedPath.replaceAll('assets:', 'assets');
      }
      if (correctedPath.contains('/Invoice/')) {
        correctedPath = correctedPath.replaceAll('/Invoice/', '/invoice/');
      }

      debugPrint('Corrected path: $correctedPath');

      // Create a temporary file to store the asset content
      final ByteData data = await rootBundle.load(correctedPath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String filePath = '$tempPath/invoice_${invoiceNumber}_download.pdf';

      // Write to temporary file
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice downloaded successfully to $filePath'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not download the PDF: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
