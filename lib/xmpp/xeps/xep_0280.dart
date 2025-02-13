import "package:moxxyv2/xmpp/managers/base.dart";
import "package:moxxyv2/xmpp/managers/namespaces.dart";
import "package:moxxyv2/xmpp/events.dart";
import "package:moxxyv2/xmpp/stanza.dart";
import "package:moxxyv2/xmpp/stringxml.dart";
import "package:moxxyv2/xmpp/namespaces.dart";
import "package:moxxyv2/xmpp/jid.dart";

class CarbonsManager extends XmppManagerBase {
  bool _isEnabled;

  CarbonsManager() : _isEnabled = false, super();
  
  @override
  String getId() => carbonsManager;

  @override
  String getName() => "CarbonsManager";

  Future<bool> enableCarbons() async {
    final result = await getAttributes().sendStanza(
      Stanza.iq(
        type: "set",
        children: [
          XMLNode.xmlns(
            tag: "enable",
            xmlns: carbonsXmlns
          )
        ]
      ),
      addFrom: true,
      addId: true
    );

    if (result.attributes["type"] != "result") {
      logger.warning("Failed to enable message carbons");

      return false;
    }

    logger.fine("Successfully enabled message carbons");

    _isEnabled = true;
    return true;
  }

  Future<bool> disableCarbons() async {
    final result = await getAttributes().sendStanza(
      Stanza.iq(
        type: "set",
        children: [
          XMLNode.xmlns(
            tag: "disable",
            xmlns: carbonsXmlns
          )
        ]
      ),
      addFrom: true,
      addId: true
    );

    if (result.attributes["type"] != "result") {
      logger.warning("Failed to disable message carbons");

      return false;
    }

    logger.fine("Successfully disabled message carbons");
    
    _isEnabled = false;
    return true;
  }

  // TODO: Reset _isEnabled if we fail stream resumption or otherwise need to assume a new
  //       state.
  @override
  void onXmppEvent(XmppEvent event) {
    if (event is ServerDiscoDoneEvent && !_isEnabled) {
      final attrs = getAttributes();

      if (attrs.isFeatureSupported(carbonsXmlns)) {
        logger.finest("Message carbons supported. Enabling...");

        enableCarbons();
      } else {
        logger.info("Message carbons not supported.");
      }
    }
  }

  bool isCarbonValid(JID senderJid) {
    return _isEnabled && senderJid == getAttributes().getConnectionSettings().jid.toBare();
  }
}
