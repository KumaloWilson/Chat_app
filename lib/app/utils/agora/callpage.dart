import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat_app/app/utils/constants/constants.dart';
import 'package:chat_app/app/view/home/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;

class Call extends StatefulWidget {
  final String channelName;

  const Call({Key? key, required this.channelName}) : super(key: key);

  @override
  State<Call> createState() => _CallState();
}

class _CallState extends State<Call> {
  late RtcEngine _engine;
  late int streamId;
  bool muted = false, loading = false;
  int _remoteUid = 0;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    setState(() {
      loading = true;
    });
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.Communication);
    streamId = (await _engine.createDataStream(false, false))!;
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        if (kDebugMode) {
          print("onJoinChannel: $channel, uid: $uid");
        }
      },
      userJoined: (uid, elapsed) {
        //when a new user joined the uid update here
        print("UserJoined: $uid");
        setState(() {
          _remoteUid = uid;
        });
      },
      userOffline: (uid, elapsed) {
        if (kDebugMode) {
          print("Useroffline: $uid");
        }
        //when the user leaves the channel update the uid
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
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 130,
                margin: const EdgeInsets.only(left: 15, top: 15),
                child: _renderLocalView(),
              ),
            ),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  Widget _renderLocalView() {
    return const RtcLocalView.SurfaceView();
  }

  Widget _renderRemoteView() {
    //which will display the remote view of the user
    if (_remoteUid != 0) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: widget.channelName,
      );
    } else {
      return const Text("Waiting for other user to join");
    }
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
          RawMaterialButton(
            onPressed: () {
              _onSwitchCamera();
            },
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(5),
            elevation: 2.0,
            fillColor: Colors.white,
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blue,
              size: 40,
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

  void _onSwitchCamera() {
    _engine.switchCamera();
  }
}
