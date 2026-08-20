part of 'upload_speaking_cubit.dart';

class UploadSpeakingState extends Equatable {
  final FormStatus status;
  final String errorMessage;
  final String message;
  final AiResponse aiResponse;

  const UploadSpeakingState({
    required this.status,
    required this.errorMessage,
    required this.aiResponse,
    required this.message,
  });

  UploadSpeakingState copyWith({
    FormStatus? status,
    String? errorMessage,
    String? message,
    AiResponse? aiResponse,
  }) {
    return UploadSpeakingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      aiResponse: aiResponse ?? this.aiResponse,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, message, aiResponse];
}
