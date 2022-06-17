import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';


final GetIt sl = GetIt.instance;
final logger = Logger();

Future<void> setup() async {
  try {
    await init();
  } catch(e) {
    logger.e('error, setup: $e');
  }
}

///!  init
Future<void> init() async {
  //! Firebase
  try {
    //! Network

    //! External
    sl.registerLazySingleton(() => http.Client());


  } catch(e) {
    logger.e('error, init: $e');
  }
}