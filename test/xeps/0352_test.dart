import "package:moxxyv2/xmpp/settings.dart";
import "package:moxxyv2/xmpp/namespaces.dart";
import "package:moxxyv2/xmpp/stringxml.dart";
import "package:moxxyv2/xmpp/jid.dart";
import "package:moxxyv2/xmpp/managers/attributes.dart";
import "package:moxxyv2/xmpp/xeps/0352.dart";

import "package:test/test.dart";

void main() {
  group("Test the XEP-0352 implementation", () {
      test("Test setting the CSI state when CSI is unsupported", () {
          bool nonzaSent = false;
          final csi = CSIManager();
          csi.register(XmppManagerAttributes(
              log: (str) => print(str),
              sendStanza: (_, { bool addFrom = true, bool addId = true}) async => XMLNode(tag: "hallo"),
              sendEvent: (event) {},
              sendNonza: (nonza) {
                nonzaSent = true;
              },
              sendRawXml: (_) {},
              getConnectionSettings: () => ConnectionSettings(
                jid: BareJID.fromString("some.user@example.server"),
                password: "password",
                useDirectTLS: true,
                allowPlainAuth: false,
              ),
              getManagerById: (_) => null,
              isStreamFeatureSupported: (_) => false,
              getFullJID: () => FullJID.fromString("some.user@example.server/aaaaa")
          ));

          csi.setActive();
          csi.setInactive();

          expect(nonzaSent, false, reason: "Expected that no nonza is sent");
      });
      test("Test setting the CSI state when CSI is supported", () {
          final csi = CSIManager();
          csi.register(XmppManagerAttributes(
              log: (str) => print(str),
              sendStanza: (_, { bool addFrom = true, bool addId = true}) async => XMLNode(tag: "hallo"),
              sendEvent: (event) {},
              sendNonza: (nonza) {
                expect(nonza.attributes["xmlns"] == CSI_XMLNS, true, reason: "Expected only nonzas with XMLNS '${CSI_XMLNS}'");
              },
              sendRawXml: (_) {},
              getConnectionSettings: () => ConnectionSettings(
                jid: BareJID.fromString("some.user@example.server"),
                password: "password",
                useDirectTLS: true,
                allowPlainAuth: false,
              ),
              getManagerById: (_) => null,
              isStreamFeatureSupported: (xmlns) => xmlns == CSI_XMLNS,
              getFullJID: () => FullJID.fromString("some.user@example.server/aaaaa")
          ));

          csi.setActive();
          csi.setInactive();
      });
  });
}
