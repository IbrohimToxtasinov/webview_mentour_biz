part of 'file_upload_cubit.dart';

class FileUploadState extends Equatable {
  final FormStatus status;
  final String errorMessage;
  final FileUploadModel fileUploadModel;

  const FileUploadState({
    required this.status,
    required this.errorMessage,
    required this.fileUploadModel,
  });

  FileUploadState copyWith({
    FormStatus? status,
    String? errorMessage,
    FileUploadModel? fileUploadModel,
  }) {
    return FileUploadState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fileUploadModel: fileUploadModel ?? this.fileUploadModel,
    );
  }

  @override
  List<Object> get props => [status, errorMessage, fileUploadModel];
}
