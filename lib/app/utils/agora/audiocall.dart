import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat_app/app/utils/constants/constants.dart';
import 'package:chat_app/app/view/home/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;

class AudioCall extends StatefulWidget {
  final String channelName;

  const AudioCall({Key? key, required this.channelName}) : super(key: key);

  @override
  State<AudioCall> createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  late RtcEngine _engine;
  bool muted = false;
  int _remoteUid = 0;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.setChannelProfile(ChannelProfile.Communication);
    await _engine.enableLocalAudio(true); // Enable local audio
    await _engine.setDefaultAudioRouteToSpeakerphone(
        true); // Set default audio route to speakerphone
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        if (kDebugMode) {
          print("onJoinChannel: $channel, uid: $uid");
        }
      },
      userJoined: (uid, elapsed) {
        // When a new user joined, update the uid here
        print("UserJoined: $uid");
        setState(() {
          _remoteUid = uid;
        });
      },
      userOffline: (uid, elapsed) {
        if (kDebugMode) {
          print("Useroffline: $uid");
        }
        // When the user leaves the channel, update the uid
        setState(() {
          _remoteUid = 0;
        });
      },
    ));
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _renderRemoteView(),
            ),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  Widget _renderRemoteView() {
    // Display the remote view of the user
    return const SizedBox(); // Return an empty SizedBox to avoid showing video
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              _onToggleMute();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            elevation: 2.0,
            fillColor: (muted) ? Colors.blue : Colors.white,
            child: Icon(
              (muted) ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blue,
              size: 40,
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              _onCallEnd();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onCallEnd() {
    _engine.leaveChannel().then((value) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Home(),
      ));
    });
  }
}
