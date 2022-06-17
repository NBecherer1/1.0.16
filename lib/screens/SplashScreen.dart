import '../services/JellyfinApiData.dart';
import 'package:flutter/material.dart';
import '../screens/ViewSelector.dart';
import '../screens/UserSelector.dart';
import '../screens/MusicScreen.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer';



class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    JellyfinApiData jellyfinApiData = GetIt.instance<JellyfinApiData>();
    if (jellyfinApiData.currentUser == null) {
      log("No saved user. Going to server selector.");
      return const UserSelector();
    } else if (jellyfinApiData.currentUser!.currentView == null) {
      log("No saved view. Going to view selector.");
      return const ViewSelector();
    } else {
      log("User and view exist. Going to music screen.");
      return const MusicScreen();
    }
  }
}
