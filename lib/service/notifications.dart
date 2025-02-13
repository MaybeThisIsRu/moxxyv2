import "package:moxxyv2/shared/models/message.dart" as model;
import "package:moxxyv2/service/xmpp.dart";

import "package:logging/logging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get_it/get_it.dart";

// TODO: Add resolution dependent drawables for the notification icon
class NotificationsService {
  // ignore: unused_field
  final Logger _log;

  NotificationsService() : _log = Logger("NotificationsService");

  Future<void> init() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings("app_icon"),
      //ios: IOSInitilizationSettings(...)
    );

    // TODO: Callback
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    GetIt.I.registerSingleton<FlutterLocalNotificationsPlugin>(flutterLocalNotificationsPlugin);
  }

  /// Returns true if a notification should be shown. false otherwise.
  bool shouldShowNotification(String jid) {
    return GetIt.I.get<XmppService>().getCurrentlyOpenedChatJid() != jid;
  }
  
  /// Show a notification for a message [m] grouped by its [conversationJid]
  /// attribute. If the message is a media message, i.e. mediaUrl != null and isMedia == true,
  /// then Android's BigPicture will be used.
  Future<void> showNotification(model.Message m, String title) async {
    // TODO: Keep track of notifications to create a summary notification
    // See https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/lib/main.dart#L1293
    // TODO: Also allow this with a generated video thumbnail
    final isImage = m.mediaType?.startsWith("image/") == true;

    final androidDetails = AndroidNotificationDetails(
      "message_channel", "Message channel",
      channelDescription: "The notification channel for received messages",
      styleInformation: (m.isMedia && m.mediaUrl != null && isImage) ? BigPictureStyleInformation(
        FilePathAndroidBitmap(m.mediaUrl!)
      ) : null,
      groupKey: m.conversationJid
    );
    final body = (m.isMedia && m.mediaUrl != null) ? "📷 Image" : m.body;
    final details = NotificationDetails(android: androidDetails);
    await GetIt.I.get<FlutterLocalNotificationsPlugin>().show(
      m.id, title, body, details
    );
  }
}
