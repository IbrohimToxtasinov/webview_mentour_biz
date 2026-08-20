part of 'library_bloc.dart';

class LibraryState extends Equatable {
  final FormStatus status;
  final String errorMessage;
  final List<VideoLibraryModel> libraryVideos;

  const LibraryState({
    required this.status,
    required this.errorMessage,
    required this.libraryVideos,
  });

  LibraryState copyWith({
    FormStatus? status,
    String? errorMessage,
    List<VideoLibraryModel>? libraryVideos,
  }) {
    return LibraryState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      libraryVideos: libraryVideos ?? this.libraryVideos,
    );
  }

  @override
  List<Object> get props => [status, errorMessage, libraryVideos];
}
