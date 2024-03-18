// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class LogoutDoneState extends ProfileState {}

class UserDataFectchedDone extends ProfileState {
  String name;
  String imageUrl;
  String id;
  UserDataFectchedDone({
    required this.name,
    required this.imageUrl,
    required this.id,
  });
}

class NavigateToProfileUpdateState extends ProfileState {}

class NavigationDoneToProfileUpdatePageState extends ProfileState {}

class ProfileSavedState extends ProfileState {
  final String name;
  ProfileSavedState({
    required this.name,
  });
}

class ProfileCancelState extends ProfileState {}

class ProfileImagePickedSuccessState extends ProfileState {
  File image;
  ProfileImagePickedSuccessState({
    required this.image,
  });
}

class ProfileImagePickedErrorState extends ProfileState{}

class ProfileImageUpdatedSuccessState extends ProfileState{}

class UserDeletedState extends ProfileState{}