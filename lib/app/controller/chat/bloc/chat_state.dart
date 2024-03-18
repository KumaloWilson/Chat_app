// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class NavigatedSearchPageDoneState extends ChatState {}

class BottomSheetSuccessState extends ChatState {}

class GalleryImageSentSuccessState extends ChatState {}

class VideoCallWorkingState extends ChatState {
  final String token;
  final String name;
  VideoCallWorkingState({
    required this.token,
    required this.name,
  });
}

class AudioCallWorkingState extends ChatState {
  final String token;
  final String name;
  AudioCallWorkingState({
    required this.token,
    required this.name,
  });
}
