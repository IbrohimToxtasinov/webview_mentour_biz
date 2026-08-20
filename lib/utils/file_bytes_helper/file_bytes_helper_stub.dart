import 'dart:io';

class FileBytesResult {
  final List<int> bytes;
  final String mimeType;
  final String extension;

  FileBytesResult({
    required this.bytes,
    required this.mimeType,
    required this.extension,
  });
}

Future<FileBytesResult> getFileBytesImpl(String path) async {
  final bytes = await File(path).readAsBytes();
  final extension = path.split('.').last;
  return FileBytesResult(
    bytes: bytes,
    mimeType: '',
    extension: extension,
  );
}
