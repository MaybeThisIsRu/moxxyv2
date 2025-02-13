import "package:moxxyv2/xmpp/managers/base.dart";
import "package:moxxyv2/xmpp/managers/namespaces.dart";
import "package:moxxyv2/xmpp/stringxml.dart";
import "package:moxxyv2/xmpp/namespaces.dart";
import "package:moxxyv2/xmpp/events.dart";
import "package:moxxyv2/xmpp/xeps/xep_0060.dart";

class UserAvatar {
  final String base64;
  final String hash;

  const UserAvatar({ required this.base64, required this.hash });
}

/// NOTE: This class requires a PubSubManager
class UserAvatarManager extends XmppManagerBase {
  @override
  String getId() => userAvatarManager;

  @override
  String getName() => "UserAvatarManager";

  PubSubManager _getPubSubManager() => getAttributes().getManagerById(pubsubManager)! as PubSubManager;
  
  @override
  void onXmppEvent(XmppEvent event) {
    if (event is PubSubNotificationEvent) {

      getAttributes().sendEvent(
        AvatarUpdatedEvent(
          jid: event.from,
          base64: event.item.payload.innerText(),
          hash: event.item.id
        )
      );
    }
  }

  /// Requests the avatar from [jid]. Returns the avatar data if the request was
  /// successful. Null otherwise
  Future<UserAvatar?> getUserAvatar(String jid) async {
    final pubsub = _getPubSubManager();
    final results = await pubsub.getItems(jid, userAvatarDataXmlns);
    if (results == null || results.isEmpty) return null;

    final item = results[0];
    return UserAvatar(
      base64: item.payload.innerText(),
      hash: item.id
    );
  }

  /// Publish the avatar data, [base64], on the pubsub node using [hash] as
  /// the item id. [hash] must be the SHA-1 hash of the image data, while
  /// [base64] must be the base64-encoded version of the image data.
  Future<bool> publishUserAvatar(String base64, String hash) async {
    final pubsub = _getPubSubManager();
    return await pubsub.publish(
      getAttributes().getFullJID().toBare().toString(),
      userAvatarDataXmlns,
      XMLNode.xmlns(
        tag: "data",
        xmlns: userAvatarDataXmlns,
        text: base64
      ),
      id: hash
    );
  }

  /// Subscribe the data node of [jid].
  Future<bool> subscribe(String jid) async {
    return await _getPubSubManager().subscribe(jid, userAvatarDataXmlns);
  }

  /// Unsubscribe the data node of [jid].
  Future<bool> unsubscribe(String jid) async {
    return await _getPubSubManager().unsubscribe(jid, userAvatarDataXmlns);
  }
}
