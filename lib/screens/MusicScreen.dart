import 'package:firebase_messaging/firebase_messaging.dart';
import '../components/MusicScreen/MusicScreenTabView.dart';
import '../components/injection/injection_container.dart';
import '../components/MusicScreen/MusicScreenDrawer.dart';
import '../components/MusicScreen/SortByMenuButton.dart';
import '../components/MusicScreen/SortOrderButton.dart';
import '../core/usecases/firebase_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:na0826/components/errorSnackbar.dart';
import 'package:na0826/models/JellyfinModels.dart';
import 'package:after_layout/after_layout.dart';
import '../services/FinampSettingsHelper.dart';
import 'package:new_version/new_version.dart';
import '../services/AudioServiceHelper.dart';
import '../services/JellyfinApiData.dart';
import '../components/NowPlayingBar.dart';
import '../core/usecases/usecase.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/FinampModels.dart';
import '../core/constants/keys.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';



class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with TickerProviderStateMixin, AfterLayoutMixin<MusicScreen> {

  TextEditingController textEditingController = TextEditingController();
  final FirebaseFirestore cloudfirestore = FirebaseFirestore.instance;
  final _audioServiceHelper = GetIt.instance<AudioServiceHelper>();
  final _jellyfinApiData = GetIt.instance<JellyfinApiData>();
  final _musicScreenLogger = Logger("MusicScreen");
  TabController? _tabController;
  bool _showShuffleFab = false;
  bool isSearching = false;
  String? searchQuery;


  @override
  void initState() {
    super.initState();
    _buildTabController();
  }

  void _stopSearching() {
    setState(() {
      textEditingController.clear();
      searchQuery = null;
      isSearching = false;
    });
  }

  void _tabIndexCallback() {
    // TODO: 9
    // if (_showShuffleFab) {
    //   setState(() {
    //     _showShuffleFab = false;
    //   });
    // }

    if (_tabController != null &&
        FinampSettingsHelper.finampSettings.showTabs.entries
            .where((element) => element.value)
            .elementAt(_tabController!.index)
            .key == TabContentType.songs) {
      if (!_showShuffleFab) {
        setState(() {
          _showShuffleFab = true;
        });
      }
    } else {
      if (_showShuffleFab) {
        setState(() {
          _showShuffleFab = false;
        });
      }
    }
  }

  void _buildTabController() {
    _tabController?.removeListener(_tabIndexCallback);
    _tabController = TabController(
      length: FinampSettingsHelper.finampSettings.showTabs.entries
        .where((element) => element.value).length,
      vsync: this,
    );
    _tabController!.addListener(_tabIndexCallback);
  }

  // TODO: 2
  Future<void> _initTracking() async {
    final inSeconds = boxInitApp.get(Keys.inSeconds);
    final parentId = boxInitApp.get(Keys.parentId);
    final idItem = boxInitApp.get(Keys.idItem);
    if (parentId != null && idItem != null) {

      List<BaseItemDto>? listItem = await _jellyfinApiData.getItemsMusicTest(
        parentId: parentId, limit: 20, sortBy: 'Album,SortName'
      );

      if (listItem != null && listItem.isNotEmpty) {
        final int index = listItem.indexWhere(((e) => e.id == idItem));
        _audioServiceHelper.queueWithItem(
          itemList: listItem, seek: inSeconds??0,
          initialIndex: (index != -1) ? index : 0
        );
      }
    }
  }


  @override
  void afterFirstLayout(BuildContext context) async {
    FirebaseNotifications.messagingListeners(cnx: context);
    _registerTopic();
    _initTracking();
    _checkVersion();
  }

  Future _checkVersion() async {
    try {
      final newVersion = NewVersion(
        iOSId: 'com.app.na0826',
        androidId: 'com.na0826.app1',
      );
      final status = await newVersion.getVersionStatus();
      if (status != null && status.canUpdate) {
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dismissAction: () {
            Navigator.pop(context);
            // SystemNavigator.pop();
          },
          allowDismissal: true,
        );
      }
    } catch(e) {
      logger.e('$e');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<FinampUser>>(
      valueListenable: _jellyfinApiData.finampUsersListenable,
      builder: (context, value, _) {
        return ValueListenableBuilder<Box<FinampSettings>>(
          valueListenable: FinampSettingsHelper.finampSettingsListener,
          builder: (context, value, _) {
            final finampSettings = value.get("FinampSettings");

            if (finampSettings!.showTabs.entries
                .where((element) => element.value)
                .length != _tabController?.length) {
              _musicScreenLogger.info(
                  "Rebuilding MusicScreen tab controller (${finampSettings.showTabs.entries.where((element) => element.value).length} != ${_tabController?.length})");
              _buildTabController();
            }

            return WillPopScope(
              onWillPop: () async {
                if (isSearching) {
                  _stopSearching();
                  return false;
                } else {
                  return true;
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage('assets/images/bg.webp'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: isSearching
                        ? TextField(
                            controller: textEditingController,
                            autofocus: true,
                            onChanged: (value) => setState(() {
                              searchQuery = value;
                            }),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search",
                            ),
                        ) : Text(_jellyfinApiData.currentUser?.currentView?.name ?? "Music"),
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: finampSettings.showTabs.entries
                          .where((element) => element.value).map((e) =>
                          Tab(text: e.key.humanReadableName.toUpperCase()))
                          .toList(),
                      // TODO: 9
                      // isScrollable: true,
                      isScrollable: false,
                    ),
                    leading: isSearching
                        ? BackButton(
                            onPressed: () => _stopSearching(),
                          ) : null,
                    actions: isSearching ? [
                            IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () => setState(() {
                                textEditingController.clear();
                                searchQuery = null;
                              }),
                              tooltip: "Clear",
                            )
                          ] : [
                            const SortOrderButton(),
                            const SortByMenuButton(),

                            // TODO: 14
                            /*
                            IconButton(
                              icon: finampSettings.isFavourite
                                  ? const Icon(Icons.star)
                                  : const Icon(Icons.star_outline),
                              onPressed: finampSettings.isOffline
                                  ? null
                                  : () => FinampSettingsHelper.setIsFavourite(
                                      !finampSettings.isFavourite),
                              tooltip: "Favourites",
                            ),
                            */
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () => setState(() {
                                isSearching = true;
                              }),
                              tooltip: "Search",
                            ),
                          ],
                  ),
                  bottomNavigationBar: const NowPlayingBar(),
                  drawer: const MusicScreenDrawer(),

                  // TODO: 9
                  floatingActionButton: _tabController!.index ==
                          finampSettings.showTabs.entries
                              .where((element) => element.value)
                              .map((e) => e.key)
                              .toList()
                              .indexOf(TabContentType.songs)
                      ? FloatingActionButton(
                          child: const Icon(Icons.shuffle),
                          tooltip: "Shuffle all",
                          onPressed: () async {
                            try {
                              await _audioServiceHelper.shuffleAll(finampSettings.isFavourite);
                            } catch (e) {
                              errorSnackbar(e, context);
                            }
                          },
                        )
                      : null,

                  body: TabBarView(
                    controller: _tabController,
                    children: finampSettings.showTabs.entries
                        .where((element) => element.value)
                        .map((e) => MusicScreenTabView(
                              tabContentType: e.key,
                              searchTerm: searchQuery,
                              isFavourite: finampSettings.isFavourite,
                              sortBy: finampSettings.sortBy,
                              sortOrder: finampSettings.sortOrder,
                              view: _jellyfinApiData.currentUser?.currentView,
                            )).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _registerTopic() async {
    String baseUrl = _jellyfinApiData.baseUrlTemp ?? _jellyfinApiData.currentUser!.baseUrl;
    String domain = '';
    final docUrl = await cloudfirestore.collection('na0826').doc('initApp').get();
    if (docUrl.exists) {
      domain = docUrl['domain'];
    }
    final query = await cloudfirestore.collection('topics').get();
    if (query.docs.isNotEmpty) {
      for (var doc in query.docs) {
        if (doc.exists) {
          if (baseUrl.contains(domain)) {
            final topic = doc['name'];
            await FirebaseMessaging.instance
                .subscribeToTopic(topic);
          } else {
            final topic = doc['name'];
            FirebaseMessaging.instance
                .unsubscribeFromTopic(topic);
          }
        }
      }
    }
  }
}
