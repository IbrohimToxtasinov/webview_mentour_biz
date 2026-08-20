part of 'unit_section_details_cubit.dart';

class UnitSectionDetailState extends Equatable {
  final String errorMessage;
  final FormStatus formStatus;
  final SectionDetailsModel section;

  const UnitSectionDetailState({
    required this.errorMessage,
    required this.formStatus,
    required this.section,
  });

  UnitSectionDetailState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    SectionDetailsModel? section,
  }) {
    return UnitSectionDetailState(
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      section: section ?? this.section,
    );
  }

  @override
  List<Object> get props => [errorMessage, formStatus, section];
}
