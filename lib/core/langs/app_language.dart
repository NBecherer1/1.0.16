import '../usecases/usecase.dart';
import '../constants/keys.dart';
import 'package:get/get.dart';
import 'dart:developer';


class AppLanguage extends GetxController {

  @override
  void onInit() {
    _getLanguage();
    super.onInit();
  }

  void saveLanguage(String lang) async {
    await boxInitApp.put(Keys.locale, lang);
    update();
  }

  void _getLanguage() async {
    final lang = boxInitApp.get(Keys.locale, defaultValue: 'en');
    log('language: $lang');
  }
}