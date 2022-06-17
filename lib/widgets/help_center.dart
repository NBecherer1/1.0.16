import 'package:na0826/widgets/responsive_safe_area.dart';
import 'package:na0826/widgets/webvew_app.dart';
import '../core/usecases/usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class HelpCenter extends StatelessWidget {
  const HelpCenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSafeArea(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('help_center'.tr),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Get.back(),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_ply_album'.tr,
                      url: howPlyAlbumLink,
                    )),
                    title: Text('how_ply_album'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.play_circle_fill),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_skip'.tr,
                      url: howSkipLink,
                    )),
                    title: Text('how_skip'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.compare_arrows),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_favourite'.tr,
                      url: howFavouriteLink,
                    )),
                    title: Text('how_favourite'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.star),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_change_track'.tr,
                      url: howChangeTrackLink,
                    )),
                    title: Text('how_change_track'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.shutter_speed),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_resume'.tr,
                      url: howResumeLink,
                    )),
                    title: Text('how_resume'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.playlist_play_sharp),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_search'.tr,
                      url: howSearchLink,
                    )),
                    title: Text('how_search'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.search),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_sleep'.tr,
                      url: howSleepLink,
                    )),
                    title: Text('how_sleep'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.shield_moon),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => WebVewApp(
                      title: 'how_download'.tr,
                      url: howDownloadLink,
                    )),
                    title: Text('how_download'.tr),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.download),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}
