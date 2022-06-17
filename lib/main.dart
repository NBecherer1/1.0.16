import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'components/injection/injection_container.dart' as di;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:na0826/services/FinampSettingsHelper.dart';
import 'screens/DownloadLocationsSettingsScreen.dart';
import 'core/usecases/firebase_notifications.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/MusicPlayerBackgroundTask.dart';
import 'screens/AudioServiceSettingsScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/AddDownloadLocationScreen.dart';
import 'screens/TranscodingSettingsScreen.dart';
import 'services/DownloadUpdateStream.dart';
import 'models/recieved_notification.dart';
import 'screens/DownloadsErrorScreen.dart';
import 'screens/LayoutSettingsScreen.dart';
import 'services/AudioServiceHelper.dart';
import 'screens/AddToPlaylistScreen.dart';
import 'screens/TabsSettingsScreen.dart';
import 'package:flutter/foundation.dart';
import 'core/network/network_info.dart';
import 'package:flutter/services.dart';
import 'services/JellyfinApiData.dart';
import 'services/DownloadsHelper.dart';
import 'package:flutter/material.dart';
import 'screens/DownloadsScreen.dart';
import 'package:logging/logging.dart';
import 'screens/SettingsScreen.dart';
import 'core/langs/translation.dart';
import 'package:rxdart/rxdart.dart';
import 'core/usecases/usecase.dart';
import 'models/JellyfinModels.dart';
import 'package:get_it/get_it.dart';
import 'generateMaterialColor.dart';
import 'screens/ArtistScreen.dart';
import 'screens/UserSelector.dart';
import 'screens/ViewSelector.dart';
import 'screens/PlayerScreen.dart';
import 'screens/SplashScreen.dart';
import 'screens/MusicScreen.dart';
import 'models/FinampModels.dart';
import 'core/constants/keys.dart';
import 'screens/AlbumScreen.dart';
import 'screens/LogsScreen.dart';
import 'package:get/get.dart';
import 'setupLogging.dart';
import 'dart:developer';
import 'dart:isolate';
import 'dart:async';
import 'dart:ui';




const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', 'High Importance Notifications',
  importance: Importance.max, playSound: true,
);


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<RecievedNotification> didReceiveNotificationSubject = BehaviorSubject<RecievedNotification>();

initializePlatformSpecifics() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  var initializationSettingsAndroid = const AndroidInitializationSettings('@drawable/ic_stat_name');
  var initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, String? title, String? body, String? payload) async {
      RecievedNotification receivedNotification = RecievedNotification(
          id: id, title: title, body: body, payload: payload);
      didReceiveNotificationSubject.add(receivedNotification);
      FirebaseNotifications.selectNotification(payload);
    },
  );
  final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: FirebaseNotifications.selectNotification,
  );
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  // log('Handling a background message ${message.messageId}');
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  AppleNotification? apple = message.notification?.apple;
  if (notification != null) {

  }
}


handleNotifications() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getInitialMessage()
      .then((value) => value != null ? _firebaseMessagingBackgroundHandler : false);
  return;
}


void main() async {
  // If the app has failed, this is set to true.
  // If true, we don't attempt to run the main app since the error app has started.
  bool hasFailed = false;
  try {
    setupLogging();
    await setupHive();
    _setupJellyfinApiData();
    await _setupDownloader();
    await _setupDownloadsHelper();
    await _setupAudioServiceHelper();
    await Firebase.initializeApp();
    await initializePlatformSpecifics();
    handleNotifications();
    FirebaseNotifications.setUpFirebase();
    await di.setup();
  } catch (e) {
    hasFailed = true;
    runApp(FinampErrorApp(
      error: e,
    ));
  }
  Get.put(NetworkInfo());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (!hasFailed) {
    final flutterLogger = Logger("Flutter");
    runZonedGuarded(() {
      FlutterError.onError = (FlutterErrorDetails details) {
        if (!kReleaseMode) {
          FlutterError.dumpErrorToConsole(details);
        }
        flutterLogger.severe(details.exception, null, details.stack);
      };
      runApp(const Finamp());
    }, (error, stackTrace) {
      flutterLogger.severe(error, null, stackTrace);
    });
  }
}

void _setupJellyfinApiData() {
  GetIt.instance.registerSingleton(JellyfinApiData());
}

Future<void> _setupDownloadsHelper() async {
  GetIt.instance.registerSingleton(DownloadsHelper());
}

Future<void> _setupDownloader() async {
  GetIt.instance.registerSingleton(DownloadUpdateStream());
  GetIt.instance<DownloadUpdateStream>().setupSendPort();

  if (kDebugMode) {
    GetIt.instance<DownloadUpdateStream>().addPrintListener();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  // flutter_downloader sometimes crashes when adding downloads. For some
  // reason, adding this callback fixes it.
  // https://github.com/fluttercommunity/flutter_downloader/issues/445

  FlutterDownloader.registerCallback(_DummyCallback.callback);
}

// TODO: move this function somewhere else since it's also run in MusicPlayerBackgroundTask.dart
Future<void> setupHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(BaseItemDtoAdapter());
  Hive.registerAdapter(UserItemDataDtoAdapter());
  Hive.registerAdapter(NameIdPairAdapter());
  Hive.registerAdapter(DownloadedSongAdapter());
  Hive.registerAdapter(DownloadedParentAdapter());
  Hive.registerAdapter(MediaSourceInfoAdapter());
  Hive.registerAdapter(MediaStreamAdapter());
  Hive.registerAdapter(AuthenticationResultAdapter());
  Hive.registerAdapter(FinampUserAdapter());
  Hive.registerAdapter(UserDtoAdapter());
  Hive.registerAdapter(SessionInfoAdapter());
  Hive.registerAdapter(UserConfigurationAdapter());
  Hive.registerAdapter(UserPolicyAdapter());
  Hive.registerAdapter(AccessScheduleAdapter());
  Hive.registerAdapter(PlayerStateInfoAdapter());
  Hive.registerAdapter(SessionUserInfoAdapter());
  Hive.registerAdapter(ClientCapabilitiesAdapter());
  Hive.registerAdapter(DeviceProfileAdapter());
  Hive.registerAdapter(DeviceIdentificationAdapter());
  Hive.registerAdapter(HttpHeaderInfoAdapter());
  Hive.registerAdapter(XmlAttributeAdapter());
  Hive.registerAdapter(DirectPlayProfileAdapter());
  Hive.registerAdapter(TranscodingProfileAdapter());
  Hive.registerAdapter(ContainerProfileAdapter());
  Hive.registerAdapter(ProfileConditionAdapter());
  Hive.registerAdapter(CodecProfileAdapter());
  Hive.registerAdapter(ResponseProfileAdapter());
  Hive.registerAdapter(SubtitleProfileAdapter());
  Hive.registerAdapter(FinampSettingsAdapter());
  Hive.registerAdapter(DownloadLocationAdapter());
  Hive.registerAdapter(ImageBlurHashesAdapter());
  Hive.registerAdapter(BaseItemAdapter());
  Hive.registerAdapter(QueueItemAdapter());
  Hive.registerAdapter(ExternalUrlAdapter());
  Hive.registerAdapter(NameLongIdPairAdapter());
  Hive.registerAdapter(TabContentTypeAdapter());
  Hive.registerAdapter(SortByAdapter());
  Hive.registerAdapter(SortOrderAdapter());
  Hive.registerAdapter(ContentViewTypeAdapter());
  await Future.wait([
    Hive.openBox<DownloadedParent>("DownloadedParents"),
    Hive.openBox<DownloadedSong>("DownloadedItems"),
    Hive.openBox<DownloadedSong>("DownloadIds"),
    Hive.openBox<FinampUser>("FinampUsers"),
    Hive.openBox<String>("CurrentUserId"),
    Hive.openBox<FinampSettings>("FinampSettings"),
    Hive.openBox<BaseItemDto>('baseItem'),
    Hive.openBox('initApp'),
  ]);

  // If the settings box is empty, we add an initial settings value here.
  Box<FinampSettings> finampSettingsBox = Hive.box("FinampSettings");
  if (finampSettingsBox.isEmpty) {
    finampSettingsBox.put("FinampSettings", await FinampSettings.create());
  }

  // TODO: 18
  final _boxInitApp = Hive.box(Keys.initApp);
  final _descending = _boxInitApp.get(Keys.descending);
  if (_descending == null) {
    FinampSettingsHelper.setSortOrder(SortOrder.descending);
    await _boxInitApp.put(Keys.descending, true);
  }

  //final _sortBy = _boxInitApp.get(Keys.sortBy);
  //if (_sortBy == null) {
    FinampSettingsHelper.setSortBy(SortBy.sortName);
    await _boxInitApp.put(Keys.sortBy, true);
  //}
  //! Transcode
  FinampSettings finampSettingsTemp = finampSettingsBox.get("FinampSettings")!;
  finampSettingsTemp.shouldTranscode = false;
  finampSettingsBox.put("FinampSettings", finampSettingsTemp);
  FinampSettingsHelper.setTranscodeBitrate((320.0 * 1000).toInt());

  // final _sortBy = _boxInitApp.get(Keys.sortBy);
  // if (_sortBy == null) {
  //   FinampSettingsHelper.setSortBy(SortBy.sortName);
  //   await _boxInitApp.put(Keys.sortBy, true);
  // }
  // Since 0.5.0 forces everyone to clear their app data and start again, these
  // checks are now useless. This allows the values to be non-nullable, which
  // helps with development.

  // If the settings box's transcoding settings (added in 0.3.0) are null, add initial values here.
  // FinampSettings finampSettingsTemp = finampSettingsBox.get("FinampSettings")!;
  // bool changesMade = false;

  // if (finampSettingsTemp.shouldTranscode == null) {
  //   changesMade = true;

  //   // For all of these, we instantiate a new class to get the default values.
  //   // We don't use create() for everything but downloadLocations since all of the other default values are set in FinampSettings's constructor.
  //   finampSettingsTemp.shouldTranscode =
  //       FinampSettings(downloadLocations: []).shouldTranscode;
  // }

  // if (finampSettingsTemp.transcodeBitrate == null) {
  //   changesMade = true;
  //   finampSettingsTemp.transcodeBitrate =
  //       FinampSettings(downloadLocations: []).transcodeBitrate;
  // }

  // // If the list of custom storage locations is null (added in 0.4.0), make an empty list here.
  // if (finampSettingsTemp.downloadLocations == null) {
  //   changesMade = true;

  //   // We create a new FinampSettings class to get the downloadLocations property
  //   FinampSettings newFinampSettings = await FinampSettings.create();

  //   finampSettingsTemp.downloadLocations = newFinampSettings.downloadLocations;
  // }

  // // If the androidStopForegroundOnPause setting is null (added in 0.4.3), set it here.
  // if (finampSettingsTemp.androidStopForegroundOnPause == null) {
  //   changesMade = true;

  //   finampSettingsTemp.androidStopForegroundOnPause =
  //       FinampSettings(downloadLocations: []).androidStopForegroundOnPause;
  // }

  // if (changesMade) {
  //   finampSettingsBox.put("FinampSettings", finampSettingsTemp);
  // }
}

Future<void> _setupAudioServiceHelper() async {
  final session = await AudioSession.instance;
  session.configure(const AudioSessionConfiguration.music());

  final _audioHandler = await AudioService.init(
    builder: () => MusicPlayerBackgroundTask(),
    config: AudioServiceConfig(
      androidStopForegroundOnPause:
      FinampSettingsHelper.finampSettings.androidStopForegroundOnPause,
      androidNotificationChannelName: "Playback",
      androidNotificationIcon: "drawable/ic_stat_name",
      androidNotificationChannelId: "com.na0826.app1.audio",
    ),
  );

  // GetIt.instance.registerSingletonAsync<AudioHandler>(
  //     () async => );

  GetIt.instance.registerSingleton<MusicPlayerBackgroundTask>(_audioHandler);
  GetIt.instance.registerSingleton(AudioServiceHelper());
}

class Finamp extends StatelessWidget {
  const Finamp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = boxInitApp.get(Keys.locale, defaultValue: 'en');
    // const Color accentColor = Colors.white; // Gray
    // const Color accentColor = Color(0xFF4e208e); // purple
    const Color accentColor = Color(0xFF00A4DC);

    // const Color raisedDarkColor = Color(0xFF82878E); // Gray
    // const Color raisedDarkColor = Color(0xFF975ad1); // Purple
    const Color raisedDarkColor = Color(0xFF202020);

    // const Color backgroundColor = Color(0xFF82878E); // Gray
    // const Color backgroundColor = Color(0xFF4e208e); // Purple
    const Color backgroundColor = Color(0xFF101010);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: GetMaterialApp(
        title: "NA 0826",
        translations: Translation(),
        locale: Locale(lang),
        fallbackLocale: Locale(lang),
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (context) => const SplashScreen(),
          "/login/userSelector": (context) => const UserSelector(),
          "/settings/views": (context) => const ViewSelector(),
          "/music": (context) => const MusicScreen(),
          "/music/albumscreen": (context) => const AlbumScreen(),
          "/music/artistscreen": (context) => const ArtistScreen(),
          "/music/addtoplaylist": (context) => const AddToPlaylistScreen(),
          "/nowplaying": (context) => const PlayerScreen(),
          "/downloads": (context) => const DownloadsScreen(),
          "/downloads/errors": (context) => const DownloadsErrorScreen(),
          "/logs": (context) => const LogsScreen(),
          "/settings": (context) => const SettingsScreen(),
          "/settings/transcoding": (context) =>
              const TranscodingSettingsScreen(),
          "/settings/downloadlocations": (context) =>
              const DownloadsSettingsScreen(),
          "/settings/downloadlocations/add": (context) =>
              const AddDownloadLocationScreen(),
          "/settings/audioservice": (context) =>
              const AudioServiceSettingsScreen(),
          "/settings/tabs": (context) => const TabsSettingsScreen(),
          "/settings/layout": (context) => const LayoutSettingsScreen(),
        },
        initialRoute: "/",
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            color: raisedDarkColor,
          ),
          cardColor: raisedDarkColor,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: raisedDarkColor),
          canvasColor: raisedDarkColor,
          toggleableActiveColor: generateMaterialColor(accentColor).shade200,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: generateMaterialColor(accentColor),
            brightness: Brightness.dark,
            accentColor: accentColor,
          ),
          indicatorColor: accentColor,
        ),
        themeMode: ThemeMode.dark,
      ),
    );
  }
}


class FinampErrorApp extends StatelessWidget {
  const FinampErrorApp({Key? key, required this.error}) : super(key: key);

  final dynamic error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NA 0826",
      home: Scaffold(
        body: Center(
          child: Text(
            "Something went wrong during app startup! The error was: ${error.toString()}\n\n"),
        ),
      ),
    );
  }
}


class _DummyCallback {
  static void callback(String id, DownloadTaskStatus status, int progress) {
    // final _downloadUpdateStream = GetIt.instance<DownloadUpdateStream>();
    // Add the event to the DownloadUpdateStream instance.
    if (status == DownloadTaskStatus.complete) {
      log("$id DONE!");
    }
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }
}
