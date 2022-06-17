import '../../services/MusicPlayerBackgroundTask.dart';
import '../../services/FinampSettingsHelper.dart';
import '../../services/JellyfinApiData.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../errorSnackbar.dart';



class LogoutListTile extends StatelessWidget {
  const LogoutListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: FinampSettingsHelper.finampSettings.isOffline
            ? null : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        "Log out",
        style: FinampSettingsHelper.finampSettings.isOffline
            ? null
            : TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
      ),
      subtitle: FinampSettingsHelper.finampSettings.isOffline
          ? const Text("Not available in offline mode")
          : Text(
              "Downloaded songs will not be deleted",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
      enabled: !FinampSettingsHelper.finampSettings.isOffline,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            // backgroundColor: const Color(0xFF82878E),
            title: const Text("Are you sure?"),
            actions: [
              TextButton(
                child: const Text("CANCEL"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("OK"),
                onPressed: () async {
                  try {
                    final _audioHandler = GetIt.instance<MusicPlayerBackgroundTask>();
                    // We don't want audio to be playing after we log out.
                    // We check if the audio service is running on iOS because
                    // stop() never completes if the service is not running.
                    if (_audioHandler.playbackState.valueOrNull?.playing == true) {
                      await _audioHandler.stop();
                    }

                    final jellyfinApiData = GetIt.instance<JellyfinApiData>();

                    await jellyfinApiData.logoutCurrentUser().onError((_, __) {});

                    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
                  } catch (e) {
                    errorSnackbar(e, context);
                    return;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
