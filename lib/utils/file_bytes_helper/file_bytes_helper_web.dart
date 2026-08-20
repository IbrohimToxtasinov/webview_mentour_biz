import 'dart:html' as html;
import 'dart:typed_data';

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
  final request = await html.HttpRequest.request(
    path,
    method: 'GET',
    responseType: 'blob',
  );
  final html.Blob blob = request.response as html.Blob;
  final mimeType = blob.type;

  String extension = 'webm';
  if (mimeType.contains('audio/webm') || mimeType.contains('video/webm')) {
    extension = 'webm';
  } else if (mimeType.contains('audio/ogg') || mimeType.contains('application/ogg')) {
    extension = 'ogg';
  } else if (mimeType.contains('audio/wav') || mimeType.contains('audio/x-wav')) {
    extension = 'wav';
  } else if (mimeType.contains('audio/mp3') || mimeType.contains('audio/mpeg')) {
    extension = 'mp3';
  } else if (mimeType.contains('audio/aac')) {
    extension = 'aac';
  } else if (mimeType.contains('audio/mp4') || mimeType.contains('audio/x-m4a')) {
    extension = 'm4a';
  }

  final reader = html.FileReader();
  reader.readAsArrayBuffer(blob);
  await reader.onLoadEnd.first;
  final Uint8List bytes = reader.result as Uint8List;

  return FileBytesResult(
    bytes: bytes,
    mimeType: mimeType,
    extension: extension,
  );
}
