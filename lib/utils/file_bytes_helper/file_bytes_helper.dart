import 'file_bytes_helper_stub.dart' if (dart.library.html) 'file_bytes_helper_web.dart' as impl;

export 'file_bytes_helper_stub.dart' if (dart.library.html) 'file_bytes_helper_web.dart' show FileBytesResult;

Future<impl.FileBytesResult> getFileBytes(String path) {
  return impl.getFileBytesImpl(path);
}
