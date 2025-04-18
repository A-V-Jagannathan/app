import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witnessing_data_app/models/firebase/notification_profile_model.dart';
import 'package:witnessing_data_app/services/notification_service.dart';

class SettingsModel extends ChangeNotifier {
  late NotificationProfile notificationProfile;

  final SharedPreferences _prefs;

  SettingsModel(this._prefs) {
    _loadSettings().then((profile) {
      debugPrint('Settings loaded, setting profile and notifying listeners');
      notificationProfile = profile;
      notifyListeners();
    });
  }

  Future<NotificationProfile> _loadSettings() async {
    // Load settings from shared preferences]
    debugPrint('Loading settings!');
    // If email is not set, then no notification profile exists
    final String? email = _prefs.getString('notificationEmail');
    bool? allowNotifications = _prefs.getBool('allowEmailNotifications');
    NotificationInterval? notificationInterval = NotificationInterval.values
        .firstWhereOrNull((interval) =>
            interval.value == _prefs.getString('notificationInterval'));

    // if no email exists, simply return a profile representative of the other settings
    if (email == null) {
      debugPrint(
          'No email found in shared preferences, returning profile based on other settings');
      if (allowNotifications == null) {
        _prefs.setBool('allowEmailNotifications', false);
        allowNotifications = false;
      }
      if (notificationInterval == null) {
        _prefs.setString(
            'notificationInterval', NotificationInterval.oneHour.value);
        notificationInterval = NotificationInterval.oneHour;
      }
      return NotificationProfile(
          allowNotifications: allowNotifications,
          notificationInterval: notificationInterval);
    }

    // if email is present, then try loading the stored profile from Firebase
    debugPrint('Loading notification profile for $email from Firebase');
    final NotificationProfile? firebaseProfile =
        await NotificationService.getNotificationProfile(email);

    if (firebaseProfile == null) {
      debugPrint('No profile found for $email in Firebase');
      final NotificationProfile newProfile = NotificationProfile(
        email: email,
        allowNotifications: allowNotifications ?? false,
        notificationInterval:
            notificationInterval ?? NotificationInterval.oneHour,
      );
      debugPrint('Creating new profile for $email in Firebase');
      return await NotificationService.createNotificationProfile(newProfile)
          .then((_) => newProfile);
    } else {
      debugPrint('Profile found for $email in Firebase');
      if (allowNotifications != null &&
          allowNotifications != firebaseProfile.allowNotifications) {
        debugPrint(
            'allowNotifications out of date from firebase. Updating from $allowNotifications to ${firebaseProfile.allowNotifications}');
        _prefs.setBool(
            'allowEmailNotifications', firebaseProfile.allowNotifications);
      }

      if (notificationInterval != null &&
          notificationInterval != firebaseProfile.notificationInterval) {
        debugPrint(
            'notificationInterval out of date from firebase. Updating from $notificationInterval to ${firebaseProfile.notificationInterval}');
        _prefs.setString(
            'notificationInterval', firebaseProfile.notificationInterval.value);
      }
      return firebaseProfile;
    }
  }

  Future<bool> updateEmail(String email) async {
    final newProfile = notificationProfile.copyWith(email: email);

    bool success = false;
    try {
      success = await NotificationService.updateNotificationProfile(
          notificationProfile.email, newProfile);
      _prefs.setString('notificationEmail', email);
      notificationProfile = newProfile;
      notifyListeners();
    } catch (e) {
      success = false;
      debugPrint('Error saving new email: $e');
    }

    return success;
  }

  Future<bool> updateAllowNotifications(bool allow) async {
    final newProfile = notificationProfile.copyWith(allowNotifications: allow);

    bool success = false;
    try {
      success = await NotificationService.updateNotificationProfile(
          notificationProfile.email, newProfile);
      _prefs.setBool('allowEmailNotifications', allow);
      notificationProfile = newProfile;
      notifyListeners();
    } catch (e) {
      success = false;
      debugPrint('Error saving new email: $e');
    }

    return success;
  }

  Future<bool> updateRepeatNotificationFrequency(
      NotificationInterval interval) async {
    final newProfile =
        notificationProfile.copyWith(notificationInterval: interval);

    bool success = false;
    try {
      success = await NotificationService.updateNotificationProfile(
          notificationProfile.email, newProfile);
      notificationProfile = newProfile;
      _prefs.setString('notificationInterval', interval.value);

      notifyListeners();
    } catch (e) {
      success = false;
      debugPrint('Error saving new email: $e');
    }

    return success;
  }
}
