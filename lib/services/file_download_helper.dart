import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FileDownloadHelper {
  /// Saves the given [bytes] directly to the device's Downloads directory
  /// so it appears in the device's File Manager / Downloads, without opening Google Drive SAF.
  static Future<File> saveFileToDownloads({
    required String fileName,
    required List<int> bytes,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

    // 1. Try public Download folder: /storage/emulated/0/Download
    // This allows the file to be directly visible in the phone's File Manager -> Downloads.
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final publicDownloadDir = Directory('/storage/emulated/0/Download');
        if (await publicDownloadDir.exists()) {
          final file = File('${publicDownloadDir.path}/$cleanFileName');
          await file.writeAsBytes(bytes, flush: true);
          debugPrint('File saved to public Download: ${file.path}');
          return file;
        }
      } catch (e) {
        debugPrint('Public /storage/emulated/0/Download write failed: $e');
      }
    }

    // 2. Try path_provider getDownloadsDirectory()
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/$cleanFileName');
        await file.writeAsBytes(bytes, flush: true);
        debugPrint('File saved to getDownloadsDirectory: ${file.path}');
        return file;
      }
    } catch (e) {
      debugPrint('getDownloadsDirectory failed: $e');
    }

    // 3. Try getExternalStorageDirectory()
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final downloadDir = Directory('${extDir.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          final file = File('${downloadDir.path}/$cleanFileName');
          await file.writeAsBytes(bytes, flush: true);
          debugPrint('File saved to getExternalStorageDirectory/Download: ${file.path}');
          return file;
        }
      } catch (e) {
        debugPrint('getExternalStorageDirectory failed: $e');
      }
    }

    // 4. Fallback to getApplicationDocumentsDirectory()
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$cleanFileName');
    await file.writeAsBytes(bytes, flush: true);
    debugPrint('File saved to getApplicationDocumentsDirectory: ${file.path}');
    return file;
  }

  /// Opens the file using the device's default application (PDF viewer, etc.)
  static Future<OpenResult> openFile(String filePath, {String? mimeType}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return OpenResult(
        type: ResultType.fileNotFound,
        message: 'File not found on device',
      );
    }

    try {
      // 1. First attempt with explicit mimeType (e.g. application/pdf)
      if (mimeType != null && mimeType.isNotEmpty) {
        final res = await OpenFilex.open(filePath, type: mimeType);
        if (res.type == ResultType.done) {
          return res;
        }
      }

      // 2. Second attempt auto-detecting by extension
      final res = await OpenFilex.open(filePath);
      if (res.type == ResultType.done) {
        return res;
      }

      // 3. Fallback to url_launcher Uri.file
      try {
        final uri = Uri.file(filePath);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          return OpenResult(type: ResultType.done, message: 'Opened via system');
        }
      } catch (_) {}

      return res;
    } catch (e) {
      debugPrint('Error opening file: $e');
      return OpenResult(
        type: ResultType.error,
        message: e.toString(),
      );
    }
  }
}
