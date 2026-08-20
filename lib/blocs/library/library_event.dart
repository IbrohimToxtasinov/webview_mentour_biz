part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
}

class GetLibraryVideos extends LibraryEvent {
  final String itemType;
  final String levelId;
  final String schoolUuid;

  const GetLibraryVideos({
    required this.itemType,
    required this.levelId,
    required this.schoolUuid,
  });

  @override
  List<Object?> get props => [itemType, levelId, schoolUuid];
}
