import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:na0826/components/injection/injection_container.dart';
import '../../core/constants/keys.dart';
import '../../core/usecases/usecase.dart';
import '../../services/FinampSettingsHelper.dart';
import 'AlbumScreenContentFlexibleSpaceBar.dart';
import '../../services/JellyfinApiData.dart';
import '../../models/JellyfinModels.dart';
import 'package:flutter/material.dart';
import 'PlaylistNameEditButton.dart';
import 'package:get_it/get_it.dart';
import 'DownloadButton.dart';
import 'SongListTile.dart';



class AlbumScreenContent extends StatefulWidget {
  final List<BaseItemDto> children;
  final BaseItemDto parent;
  const AlbumScreenContent({
    Key? key,
    required this.parent,
    required this.children,
  }) : super(key: key);

  @override
  _AlbumScreenContentState createState() => _AlbumScreenContentState();
}

class _AlbumScreenContentState extends State<AlbumScreenContent> {

  final jellyfinApiData = GetIt.instance<JellyfinApiData>();
  List<List<BaseItemDto>> childrenPerDisc = [];
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    _initAlbum();
  }

  Future _initAlbum() async {
    try {
      if (widget.parent.type != "Playlist" && widget.children[0].parentIndexNumber != null) {
        int? lastDiscNumber;
        for (var child in widget.children) {
          if (child.parentIndexNumber != null && child.parentIndexNumber != lastDiscNumber) {
            lastDiscNumber = child.parentIndexNumber;
            childrenPerDisc.add([]);
          }
          childrenPerDisc.last.add(child);
        }
      }
      isFavourite = boxInitApp.containsKey(widget.parent.id);
    } catch(e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.parent.name ?? "Unknown Name"),
            // 125 + 64 is the total height of the widget we use as a
            // FlexibleSpaceBar. We add the toolbar height since the widget
            // should appear below the appbar.
            // TODO: This height is affected by platform density.
            expandedHeight: kToolbarHeight + 125 + 64,
            pinned: true,
            flexibleSpace: AlbumScreenContentFlexibleSpaceBar(
              album: widget.parent,
              items: widget.children,
            ),
            actions: [
              if (widget.parent.type == "Playlist" && !FinampSettingsHelper.finampSettings.isOffline)
                PlaylistNameEditButton(playlist: widget.parent),
              IconButton(
                icon: isFavourite
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_outline),
                onPressed: () async {
                  if (isFavourite) {
                    await jellyfinApiData.removeFavourite(widget.parent.id);
                    await boxInitApp.delete(widget.parent.id);
                  } else {
                    await jellyfinApiData.addFavourite(widget.parent.id);
                    await boxInitApp.put(widget.parent.id, widget.parent.id);
                  }
                  setState(() {
                    isFavourite = !isFavourite;
                  });
                },
                tooltip: "Favourites",
              ),
              // TODO: 15
              DownloadButton(parent: widget.parent, items: widget.children),
              //DownloadButton(parent: parent, items: children)
            ],
          ),
          if (childrenPerDisc.length > 1) // show headers only for multi disc albums
            for (var childrenOfThisDisc in childrenPerDisc)
              SliverStickyHeader(
                header: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                      "Disc " + childrenOfThisDisc[0].parentIndexNumber.toString(),
                      style: const TextStyle(fontSize: 20.0)
                  ),
                ),
                sliver: _SongsSliverList(
                    childrenForList: childrenOfThisDisc,
                    childrenForQueue: widget.children,
                    parentId: widget.parent.id
                ),
              )
          else _SongsSliverList(
              childrenForList: widget.children,
              childrenForQueue: widget.children,
              parentId: widget.parent.id
          ),
        ],
      ),
    );
  }
}

class _SongsSliverList extends StatelessWidget {
  const _SongsSliverList({
    Key? key,
    required this.childrenForList,
    required this.childrenForQueue,
    required this.parentId,
  }) : super(key: key);

  final List<BaseItemDto> childrenForList;
  final List<BaseItemDto> childrenForQueue;
  final String? parentId;

  @override
  Widget build(BuildContext context) {
    // When user selects song from disc other than first, index number is
    // incorrect and song with the same index on first disc is played instead.
    // Adding this offset ensures playback starts for nth song on correct disc.
    int indexOffset = childrenForQueue.indexOf(childrenForList[0]);
    // print('indexOffset: $indexOffset');
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        final BaseItemDto item = childrenForList[index];
        return SongListTile(
          item: item,
          children: childrenForQueue,
          index: index + indexOffset,
          parentId: parentId,
        );
      }, childCount: childrenForList.length),
    );
  }
}
