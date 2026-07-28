// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'Tripline';

  @override
  String get explore => 'دریافت کریں';

  @override
  String get map => 'نقشہ';

  @override
  String get trips => 'سفر';

  @override
  String get favorites => 'پسندیدہ';

  @override
  String get profile => 'پروفائل';

  @override
  String get goodMorning => 'صبح بخیر';

  @override
  String get goodAfternoon => 'دوپہر بخیر';

  @override
  String get goodEvening => 'شام بخیر';

  @override
  String get exploreDestinations => 'منزلیں دریافت کریں!';

  @override
  String get findNextTrip => 'اپنا اگلا یادگار سفر تلاش کریں';

  @override
  String get searchHint => 'منزل یا ملک تلاش کریں…';

  @override
  String get popularDestinations => 'مقبول منزلیں';

  @override
  String get recommendedForYou => 'آپ کے لیے تجویز کردہ';

  @override
  String get results => 'نتائج';

  @override
  String get places => 'مقامات';

  @override
  String get noDestinationsFound =>
      'کوئی منزل نہیں ملی۔\nریفریش کے لیے نیچے کھینچیں۔';

  @override
  String noResultsFor(String query) {
    return '\"$query\" کے لیے کوئی نتیجہ نہیں';
  }

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get account => 'اکاؤنٹ';

  @override
  String get editProfile => 'پروفائل میں ترمیم کریں';

  @override
  String get changePassword => 'پاس ورڈ تبدیل کریں';

  @override
  String get notifications => 'اطلاعات';

  @override
  String get enablePushNotifications => 'پش اطلاعات فعال کریں';

  @override
  String get travelReminders => 'سفر کی یاد دہانیاں';

  @override
  String get notificationsCenter => 'اطلاعات سینٹر';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get language => 'زبان';

  @override
  String get about => 'متعلق';

  @override
  String get appVersion => 'ایپ ورژن';

  @override
  String get termsOfService => 'شرائط و ضوابط';

  @override
  String get privacyPolicy => 'رازداری کی پالیسی';

  @override
  String get supportFaqs => 'مدد اور سوالات';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get logoutConfirm =>
      'کیا آپ واقعی Tripline سے لاگ آؤٹ کرنا چاہتے ہیں؟';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get skip => 'نظرانداز کریں';

  @override
  String get next => 'اگلا';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get signIn => 'سائن اِن';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';
}
