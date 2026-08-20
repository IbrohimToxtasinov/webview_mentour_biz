part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final ProfileModel profileModel;

  const ProfileState({
    required this.formStatus,
    required this.errorMessage,
    required this.profileModel,
  });

  ProfileState copyWith({
    FormStatus? formStatus,
    String? errorMessage,
    ProfileModel? profileModel,
  }) {
    return ProfileState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      profileModel: profileModel ?? this.profileModel,
    );
  }

  @override
  List<Object?> get props => [formStatus, errorMessage, profileModel];
}
