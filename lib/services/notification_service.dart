import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:witnessing_data_app/models/firebase/notification_profile_model.dart';
import 'package:witnessing_data_app/services/firebase_service.dart';

class NotificationService {
  NotificationService._privateConstructor();

  static final _notificationController = WitnessingDatabase.instance
      .collection(WitnessingDatabase.collections.notificationProfiles)
      .withConverter<NotificationProfile?>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            data?['email'] = snapshot.id;

            return data == null ? null : NotificationProfile.fromJson(data);
          },
          toFirestore: (notificationProfile, _) =>
              notificationProfile!.toJson());

  static Future<bool> createNotificationProfile(
      NotificationProfile notificationProfile) async {
    try {
      await _notificationController
          .doc(notificationProfile.email)
          .set(notificationProfile);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<NotificationProfile?> getNotificationProfile(
      String email) async {
    final snapshot = await _notificationController.doc(email).get();
    return snapshot.data();
  }

  static Future<bool> updateNotificationProfile(
      String oldEmail, NotificationProfile newProfile) async {
    // remove the old record and create a new one
    try {
      // if the old and new are both empty, then there's nothing to do
      if (oldEmail.isEmpty && newProfile.email.isEmpty) {
        debugPrint(
            'Both old and new notification emails are empty. No calls to Firebase needed');
        return true;
      }
      // if old is not empty and new one is, delete the record
      else if (oldEmail.isNotEmpty && newProfile.email.isEmpty) {
        debugPrint('New notification email is empty, deleting old record');
        return await _notificationController.doc(oldEmail).delete().then((_) {
          return true;
        });
      }
      // if the old is empty and the new one is not, create a new record
      else if (oldEmail.isEmpty && newProfile.email.isNotEmpty) {
        debugPrint('Old notification email is empty, creating new record');
        return await createNotificationProfile(newProfile);
      }

      // both emails are not empty and different, delete and replace
      if (oldEmail != newProfile.email) {
        // run a transaction to ensure that the old record is deleted before the new one is created
        // This ensures atomicity of the operation
        debugPrint(
            'updating notification profile with new email: transaction to delete and replace');
        return await WitnessingDatabase.instance
            .runTransaction<bool>((transaction) async {
          transaction.delete(_notificationController.doc(oldEmail));
          transaction.set<NotificationProfile?>(
              _notificationController.doc(newProfile.email), newProfile);
          return true;
        });
      }
      // both emails are the same, update the record
      else {
        debugPrint(
            'updating notification profile with same email: merging data');
        await _notificationController
            .doc(oldEmail)
            .set(newProfile, SetOptions(merge: true));
        return true;
      }
    } catch (e) {
      debugPrint('Error updating notification profile: $e');
      return false;
    }
  }
}
