// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tripline';

  @override
  String get explore => 'Explore';

  @override
  String get map => 'Map';

  @override
  String get trips => 'Trips';

  @override
  String get favorites => 'Favorites';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get exploreDestinations => 'Explore Destinations!';

  @override
  String get findNextTrip => 'Find your next unforgettable trip';

  @override
  String get searchHint => 'Search destinations or countries…';

  @override
  String get popularDestinations => 'Popular Destinations';

  @override
  String get recommendedForYou => 'Recommended For You';

  @override
  String get results => 'Results';

  @override
  String get places => 'places';

  @override
  String get noDestinationsFound => 'No destinations found.\nPull to refresh.';

  @override
  String noResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notifications => 'Notifications';

  @override
  String get enablePushNotifications => 'Enable Push Notifications';

  @override
  String get travelReminders => 'Travel Reminders';

  @override
  String get notificationsCenter => 'Notifications Center';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get supportFaqs => 'Support & FAQs';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to log out of Tripline?';

  @override
  String get cancel => 'Cancel';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get signIn => 'Sign In';

  @override
  String get createAccount => 'Create Account';
}
