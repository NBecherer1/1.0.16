import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../components/FirstPageProgressIndicator.dart';
import '../components/NewPageProgressIndicator.dart';
import '../components/MusicScreen/AlbumItem.dart';
import '../components/errorSnackbar.dart';
import '../services/JellyfinApiData.dart';
import '../models/JellyfinModels.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get/get.dart';




class FavouritePage extends StatefulWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {

  final PagingController<int, BaseItemDto> _pagingController = PagingController(firstPageKey: 0);
  JellyfinApiData jellyfinApiData = GetIt.instance<JellyfinApiData>();
  static const _pageSize = 100;

  Future<void> _getPage(int pageKey) async {
    try {
      final newItems = await jellyfinApiData.getItems(
        // If no parent item is specified, we try the view given as an argument.
        // If the view argument is null, fall back to the user's current view.
        parentItem:  jellyfinApiData.currentUser?.currentView,
        includeItemTypes: 'MusicAlbum',
        // includeItemTypes: _includeItemTypes(widget.tabContentType),

        // If we're on the songs tab, sort by "Album,SortName". This is what the
        // Jellyfin web client does. If this isn't the case, check if parentItem
        // is null. parentItem will be null when this widget is not used in an
        // artist view. If it's null, sort by "SortName". If it isn't null, check
        // if the parentItem is a MusicArtist. If it is, sort by year. Otherwise,
        // sort by SortName. If widget.sortBy is set, it is used instead.
        sortBy: "Album,SortName",
        sortOrder: SortOrder.ascending.humanReadableName,
        // searchTerm: widget.searchTerm,
        // If this is the genres tab, tell getItems to get genres.
        // TODO: 9
        isGenres: false,
        // isGenres: widget.tabContentType == TabContentType.genres,
        filters: "IsFavorite",
        startIndex: pageKey,
        // limit: _pageSize,
      );
      if (newItems!.length < _pageSize) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + newItems.length);
      }
    } catch (e) {
      errorSnackbar(e, context);
    }
  }


  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _getPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('favorites'.tr),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedGridView(
            pagingController: _pagingController,
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            builderDelegate: PagedChildBuilderDelegate<BaseItemDto>(
              itemBuilder: (context, item, index) {
                return AlbumItem(
                  album: item,
                  parentType: jellyfinApiData.currentUser!.currentView!.type!,
                  isGrid: true,
                  gridAddSettingsListener: false,
                );
              },
              firstPageProgressIndicatorBuilder: (_) =>
              const FirstPageProgressIndicator(),
              newPageProgressIndicatorBuilder: (_) =>
              const NewPageProgressIndicator(),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          ),
      ),
    );
  }
}
