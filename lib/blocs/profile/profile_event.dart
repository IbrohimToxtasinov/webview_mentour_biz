part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class GetProfileInfo extends ProfileEvent {
  const GetProfileInfo();

  @override
  List<Object?> get props => [];
}

class EditPassword extends ProfileEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const EditPassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

class UpdateProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String imageId;

  const UpdateProfile({
    required this.firstName,
    required this.lastName,
    required this.imageId,
  });

  @override
  List<Object?> get props => [firstName, lastName];
}
