import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Mobile-specific export functionality
class PlatformExportService {
  // Mobile implementation for native sharing
  static Future<bool> tryNativeShare(List<int> bytes, String fileName, String mimeType) async {
    try {
      // Create a temporary file to share
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Share the file using share_plus
      await Share.shareXFiles(
        [XFile(tempFile.path, name: fileName, mimeType: mimeType)],
        text: 'IPC Calculator Export - $fileName',
      );

      // Clean up the temporary file
      await tempFile.delete();
      return true;
    } catch (e) {
      debugPrint('Mobile share failed: $e');
      return false;
    }
  }

  // Mobile implementation for download (save to device)
  static Future<void> downloadFile(List<int> bytes, String fileName, String mimeType) async {
    try {
      // Get the application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${appDocDir.path}/exports');

      // Create exports directory if it doesn't exist
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      // Save the file to the exports directory
      final file = File('${exportsDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('File saved to: ${file.path}');
    } catch (e) {
      debugPrint('Mobile download failed: $e');
      rethrow;
    }
  }

  // Mobile always supports native sharing via share_plus
  static bool get supportsNativeSharing {
    return true;
  }

  // Get sharing capability description for user
  static String get sharingCapabilityDescription {
    return 'Share to Mail, WhatsApp, Drive, and other apps';
  }
}
