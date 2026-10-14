import 'dart:io';
import 'api_client.dart';
import 'api_config.dart';

class UploadedFile {
  final int id;
  final String originalName;
  final String storageUrl;
  final String mimeType;
  final int sizeBytes;
  final String url;

  UploadedFile({
    required this.id,
    required this.originalName,
    required this.storageUrl,
    required this.mimeType,
    required this.sizeBytes,
    required this.url,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      originalName: json['original_name']?.toString() ?? '',
      storageUrl: json['storage_url']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
      sizeBytes: json['size_bytes'] is int
          ? json['size_bytes'] as int
          : int.tryParse(json['size_bytes']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'original_name': originalName,
        'storage_url': storageUrl,
        'mime_type': mimeType,
        'size_bytes': sizeBytes,
        'url': url,
      };
}

class FilesService {
  /// POST /api/files - Upload Generic Document / Media
  /// Field: file (supports jpg, png, webp, pdf, doc, docx, max 10MB)
  static Future<UploadedFile> uploadFile(File file) async {
    final response = await ApiClient.multipartPost(
      ApiConfig.files,
      fileField: 'file',
      file: file,
    );

    if (response is Map<String, dynamic>) {
      final fileData = response['file'] is Map<String, dynamic>
          ? response['file'] as Map<String, dynamic>
          : response['data'] is Map<String, dynamic>
              ? (response['data']['file'] is Map<String, dynamic>
                  ? response['data']['file'] as Map<String, dynamic>
                  : response['data'] as Map<String, dynamic>)
              : response;
      return UploadedFile.fromJson(fileData);
    }

    throw const ApiException(
      code: 'UPLOAD_FAILED',
      message: 'Failed to upload file to server.',
      statusCode: 500,
    );
  }
}
