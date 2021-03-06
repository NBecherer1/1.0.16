import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

import '../../components/errorSnackbar.dart';
import '../../models/JellyfinModels.dart';
import '../../services/DownloadUpdateStream.dart';
import '../../services/DownloadsHelper.dart';

class DownloadedIndicator extends StatefulWidget {
  const DownloadedIndicator({
    Key? key,
    required this.item,
    required this.isSong,
  }) : super(key: key);

  final BaseItemDto item;
  final bool isSong;

  @override
  _DownloadedIndicatorState createState() => _DownloadedIndicatorState();
}

class _DownloadedIndicatorState extends State<DownloadedIndicator> {
  final _downloadsHelper = GetIt.instance<DownloadsHelper>();
  final _downloadUpdateStream = GetIt.instance<DownloadUpdateStream>();

  late Future<List<DownloadTask>?> _downloadedIndicatorFuture;
  String? _downloadTaskId;

  DownloadTaskStatus? _currentStatus;

  @override
  void initState() {
    super.initState();
    _downloadedIndicatorFuture =
        _downloadsHelper.getDownloadStatus([widget.item.id]);

    // We do this instead of using a StreamBuilder because the StreamBuilder
    // kept dropping events. With this, we can also make it so that the widget
    // only rebuilds when it actually has to.
    _downloadUpdateStream.stream.listen((event) {
      if (event.id == _downloadTaskId && event.status != _currentStatus) {
        setState(() {
          _currentStatus = event.status;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DownloadTask>?>(
      future: _downloadedIndicatorFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            _downloadTaskId = snapshot.data?[0].taskId;
            _currentStatus = snapshot.data?[0].status;
          }
          // This ValueListenable is used to get the download task ID of new
          // downloads. It also clears the task ID and status when the download
          // is deleted. This only rebuilds when the item with key
          // widget.item.id is changed, so this should only rebuild when the
          // item is first downloaded and when it is deleted.
          return ValueListenableBuilder<Box<DownloadedSong>>(
            valueListenable: _downloadsHelper
                .getDownloadedItemsListenable(keys: [widget.item.id]),
            builder: (context, box, _) {
              if (_downloadTaskId == null && box.get(widget.item.id) != null) {
                _downloadTaskId = box.get(widget.item.id)!.downloadId;
              } else if (box.get(widget.item.id) == null) {
                _downloadTaskId = null;
                _currentStatus = null;
              }
              // return StreamBuilder<DownloadUpdate>(
              //   stream: _downloadUpdateStream.stream,
              //   builder: (context, snapshot) {
              // print("Streambuilder rebuild ${snapshot.data}");
              // if (snapshot.hasData &&
              //     snapshot.data!.id == _downloadTask?.taskId) {
              //   print("Change $_currentStatus to ${snapshot.data?.status}");
              //   if (snapshot.data?.status == DownloadTaskStatus.complete) {
              //     print(
              //         "COMPLETE IN STREAMBUILDER ${widget.item.name}!!!!");
              //   }
              //   _currentStatus = snapshot.data?.status;
              // }
              if (_currentStatus == null) {
                if (widget.isSong) {
                  return IconButton(
                    icon: const Icon(Icons.downloading, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _downloadsHelper.addDownloadedItem(widget.item);
                      });
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              } else if (_currentStatus == DownloadTaskStatus.complete) {
                return IconButton(
                  icon: Icon(
                    Icons.file_download,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    _downloadsHelper.deleteDownloadItem(
                      jellyfinItemId: widget.item.id,
                      deletedFor: widget.item.id,
                    );
                  },
                );
              } else if (_currentStatus == DownloadTaskStatus.failed ||
                  _currentStatus == DownloadTaskStatus.undefined) {
                return const Icon(
                  Icons.error,
                  color: Colors.red,
                );
              } else if (_currentStatus == DownloadTaskStatus.paused) {
                return const Icon(
                  Icons.pause,
                  color: Colors.yellow,
                );
              } else if (_currentStatus == DownloadTaskStatus.enqueued ||
                  _currentStatus == DownloadTaskStatus.running) {
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Lottie.asset('assets/icon/download.json',
                      width: 35, height: 35),
                );
              } else {
                return const SizedBox(width: 0, height: 0);
              }
            },
          );
        } else if (snapshot.hasError) {
          errorSnackbar(snapshot.error, context);
          return const SizedBox(width: 0, height: 0);
        } else {
          return const SizedBox(width: 0, height: 0);
        }
      },
    );
  }
}
