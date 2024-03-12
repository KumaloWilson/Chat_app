// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatShareEvent extends ChatEvent {
  final String currentId;
  final String friendId;
  final String message;
  ChatShareEvent({
    required this.currentId,
    required this.friendId,
    required this.message,
  });
}

class NavigateToSearchPageEvent extends ChatEvent {}

class BottomSheetEvent extends ChatEvent {}

class ChatImageShareEvent extends ChatEvent {
  final String currentId;
  final String friendId;
  final String message;
  ChatImageShareEvent({
    required this.currentId,
    required this.friendId,
    required this.message,
  });
}

class GalleryImagesSentEvent extends ChatEvent {
  final String currentId;
  final String friendId;
  GalleryImagesSentEvent({
    required this.currentId,
    required this.friendId,
  });
}

class LocationSentEvent extends ChatEvent {
  final String currentId;
  final String friendId;
  LocationSentEvent({
    required this.currentId,
    required this.friendId,
  });
}

class CameraImagesSentEvent extends ChatEvent {
  final String currentId;
  final String friendId;
  CameraImagesSentEvent({
    required this.currentId,
    required this.friendId,
  });
}

class VideoCallButtonClickedEvent extends ChatEvent {
  final String friendId;
  VideoCallButtonClickedEvent({
    required this.friendId,
  });
}
