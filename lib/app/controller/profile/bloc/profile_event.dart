// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class ProfileInitailEvent extends ProfileEvent {}

class LouOutEvent extends ProfileEvent {}

class NavigateToprofileUpdatePageEvent extends ProfileEvent {}

class FetchingUserDataEvent extends ProfileEvent {}

class ProfileDataSaveEvent extends ProfileEvent {
  String userName;
  ProfileDataSaveEvent({
    required this.userName,
  });
}

class ProfileDataCancelEvent extends ProfileEvent {}

class ProfileImageUpdateEvent extends ProfileEvent {}

class ProfileSaveToDbEvent extends ProfileEvent {
  final image;
  ProfileSaveToDbEvent({required this.image});
}

class DeleteButtonClickedEvent extends ProfileEvent{}