import '../components/AudioServiceSettingsScreen/SongShuffleItemCountEditor.dart';
import '../components/AudioServiceSettingsScreen/StopForegroundSelector.dart';
import 'package:flutter/material.dart';



class AudioServiceSettingsScreen extends StatelessWidget {
  const AudioServiceSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Service"),
      ),
      body: Scrollbar(
        child: ListView(
          children: const [
            StopForegroundSelector(),
            SongShuffleItemCountEditor(),
          ],
        ),
      ),
    );
  }
}
