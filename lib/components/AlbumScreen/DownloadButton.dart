import 'package:flutter/cupertino.dart';

import '../../services/FinampSettingsHelper.dart';
import '../../core/network/network_info.dart';
import '../../services/DownloadsHelper.dart';
import '../../services/JellyfinApiData.dart';
import '../../models/JellyfinModels.dart';
import '../../widgets/flash_helper.dart';
import '../../models/FinampModels.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../errorSnackbar.dart';
import 'package:get/get.dart';
import 'DownloadDialog.dart';




class DownloadButton extends StatefulWidget {
  const DownloadButton({
    Key? key,
    required this.parent,
    required this.items,
  }) : super(key: key);

  final BaseItemDto parent;
  final List<BaseItemDto> items;

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final _downloadsHelper = GetIt.instance<DownloadsHelper>();
  final _jellyfinApiData = GetIt.instance<JellyfinApiData>();
  late bool isDownloaded;
  bool progress = false;

  @override
  void initState() {
    super.initState();
    isDownloaded = _downloadsHelper.isAlbumDownloaded(widget.parent.id);
  }

  @override
  Widget build(BuildContext context) {
    void _checkIfDownloaded() => setState(() {
      isDownloaded = _downloadsHelper.isAlbumDownloaded(widget.parent.id);
    });

    return ValueListenableBuilder<Box<FinampSettings>>(
      valueListenable: FinampSettingsHelper.finampSettingsListener,
      builder: (context, box, child) {
        bool? isOffline = box.get("FinampSettings")?.isOffline;
        if (progress) {
          return Container(
            padding: const EdgeInsets.only(right: 12),
            child: const Center(child: CupertinoActivityIndicator()),
          );
        } else {
          return IconButton(
          icon: isDownloaded
              ? const Icon(Icons.delete)
              : const Icon(Icons.file_download),
          // If offline, we don't allow the user to delete items.
          // If we did, we'd have to implement listeners for MusicScreenTabView so that the user can't delete a parent, go back, and select the same parent.
          // If they did, AlbumScreen would show an error since the item no longer exists.
          // Also, the user could delete the parent and immediately redownload it, which will either cause unwanted network usage or cause more errors becuase the user is offline.
          onPressed: isOffline ?? false ? null : () async {
                  if (isDownloaded) {
                    setState(() {
                      progress = true;
                    });
                    await _downloadsHelper.deleteDownloads(
                      jellyfinItemIds: widget.items.map((e) => e.id).toList(),
                      deletedFor: widget.parent.id,
                    ).then((_) {
                      _checkIfDownloaded();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Downloads deleted.")));
                    }, onError: (error, stackTrace) => errorSnackbar(error, context));
                    setState(() {
                      progress = false;
                    });
                  } else {
                    if (FinampSettingsHelper.finampSettings.downloadLocations.length == 1) {
                      if (NetworkInfo.isConnected) {
                        setState(() {
                          progress = true;
                        });
                        await checkedAddDownloads(
                          context, downloadLocation: FinampSettingsHelper
                            .finampSettings.downloadLocations.first,
                          parents: [widget.parent],
                          items: [widget.items],
                          viewId: _jellyfinApiData.currentUser!.currentViewId!,
                        ).whenComplete(() => _checkIfDownloaded());
                        setState(() {
                          progress = false;
                        });
                      } else {
                        FlashHelper.infoBar(context: context, message: 'error_connection'.tr);
                      }
                    } else {
                      await showDialog(
                        context: context,
                        builder: (context) => DownloadDialog(
                          parents: [widget.parent],
                          items: [widget.items],
                          viewId: _jellyfinApiData.currentUser!.currentViewId!,
                        ),
                      ).whenComplete(() => _checkIfDownloaded());
                    }
                  }
                },
        );
        }
      },
    );
  }
}
