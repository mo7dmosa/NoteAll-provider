import 'package:flutter/material.dart';
import 'package:note_all/preferences/shared_pref_controller.dart';

class LanguageProvider extends ChangeNotifier {
  String language =
      SharedPrefController().getValueFor<String>(key: PrefKeys.lang.name) ??
          'en';

  void changeLanguage() {
    language = language == 'en' ? 'ar' : 'en';
    SharedPrefController().changeLanguage(language: language);
    notifyListeners();
  }
}
