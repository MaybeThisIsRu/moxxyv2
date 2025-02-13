import "dart:async";

import "package:moxxyv2/xmpp/connection.dart";
import "package:moxxyv2/xmpp/settings.dart";
import "package:moxxyv2/xmpp/stringxml.dart";
import "package:moxxyv2/xmpp/jid.dart";
import "package:moxxyv2/xmpp/stanza.dart";
import "package:moxxyv2/xmpp/presence.dart";
import "package:moxxyv2/xmpp/roster.dart";
import "package:moxxyv2/xmpp/events.dart";
import "package:moxxyv2/xmpp/managers/attributes.dart";
import "package:moxxyv2/xmpp/managers/handlers.dart";
import "package:moxxyv2/xmpp/xeps/xep_0030/xep_0030.dart";

import "helpers/xmpp.dart";
import "helpers/moxdns.dart";

import "package:test/test.dart";

/// Returns true if the roster manager triggeres an event for a given stanza
Future<bool> testRosterManager(String bareJid, String resource, String stanzaString) async {
  bool eventTriggered = false;
  final roster = RosterManager();
  roster.register(XmppManagerAttributes(
      sendStanza: (_, { bool addFrom = true, bool addId = true}) async => XMLNode(tag: "hallo"),
      sendEvent: (event) {
        eventTriggered = true;
      },
      sendNonza: (_) {},
      sendRawXml: (_) {},
      getConnectionSettings: () => ConnectionSettings(
        jid: JID.fromString(bareJid),
        password: "password",
        useDirectTLS: true,
        allowPlainAuth: false,
      ),
      getManagerById: (_) => null,
      isStreamFeatureSupported: (_) => false,
      isFeatureSupported: (_) => false,
      getFullJID: () => JID.fromString("$bareJid/$resource")
  ));

  final stanza = Stanza.fromXMLNode(XMLNode.fromString(stanzaString));
  await Future.forEach(
    roster.getStanzaHandlers(),
    (StanzaHandler handler) async {
      if (handler.matches(stanza)) {
        await handler.callback(stanza);
      }
    }
  );

  return eventTriggered;
}

void main() {
  test("Test a successful login attempt with no SM", () async {
      final fakeSocket = StubTCPSocket(
        play: [
          Expectation(
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "to": "test.server",
                "xml:lang": "en"
              },
              closeTag: false
            ),
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "from": "test.server",
                "xml:lang": "en"
              },
              closeTag: false,
              children: [
                XMLNode.xmlns(
                  tag: "stream:features",
                  xmlns: "http://etherx.jabber.org/streams",
                  children: [
                    XMLNode.xmlns(
                      tag: "mechanisms",
                      xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
                      children: [
                        XMLNode(tag: "mechanism", text: "PLAIN")
                      ]
                    )
                  ]
                )
              ]
            )
          ),
          Expectation(XMLNode.xmlns(
              tag: "auth",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              attributes: {
                "mechanism": "PLAIN"
              },
              text: "AHBvbHlub21kaXZpc2lvbgBhYWFh"
            ),
            XMLNode.xmlns(
              tag: "success",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl"
            )
          ),
          Expectation(
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "to": "test.server",
                "xml:lang": "en"
              },
              closeTag: false
            ),
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "from": "test.server",
                "xml:lang": "en"
              },
              closeTag: false,
              children: [
                XMLNode.xmlns(
                  tag: "stream:features",
                  xmlns: "http://etherx.jabber.org/streams",
                  children: [
                    XMLNode.xmlns(
                      tag: "bind",
                      xmlns: "urn:ietf:params:xml:ns:xmpp-bind",
                      children: [
                        XMLNode(tag: "required")
                      ]
                    ),
                    XMLNode.xmlns(
                      tag: "session",
                      xmlns: "urn:ietf:params:xml:ns:xmpp-session",
                      children: [
                        XMLNode(tag: "optional")
                      ]
                    ),
                    XMLNode.xmlns(
                      tag: "csi",
                      xmlns: "urn:xmpp:csi:0",
                    )
                  ]
                )
              ]
            ),            
          ),
          Expectation(
            XMLNode.xmlns(
              tag: "iq",
              xmlns: "jabber:client",
              attributes: { "type": "set", "id": "a" },
              children: [
                XMLNode.xmlns(
                  tag: "bind",
                  xmlns: "urn:ietf:params:xml:ns:xmpp-bind"
                )
              ]
            ),
            XMLNode.xmlns(
              tag: "iq",
              xmlns: "jabber:client",
              attributes: { "type": "result" },
              children: [
                XMLNode.xmlns(
                  tag: "bind",
                  xmlns: "urn:ietf:params:xml:ns:xmpp-bind",
                  children: [
                    XMLNode(
                      tag: "jid",
                      text: "polynomdivision@test.server/MU29eEZn"
                    )
                  ]
                )
              ]
            )
          ),
          Expectation(
            XMLNode.xmlns(
              tag: "presence",
              xmlns: "jabber:client",
              attributes: { "from": "polynomdivision@test.server/MU29eEZn" },
              children: [
                XMLNode(
                  tag: "show",
                  text: "chat"
                ),
                XMLNode.xmlns(
                  tag: "c",
                  xmlns: "http://jabber.org/protocol/caps",
                  attributes: {
                    // TODO: Somehow make the test ignore this attribute
                    "ver": "QRTBC5cg/oYd+UOTYazSQR4zb/I=",
                    "node": "http://moxxy.im",
                    "hash": "sha-1"
                  }
                )
              ]
            ),
            XMLNode(
              tag: "presence",
            )
          ),
        ]
      );
      final XmppConnection conn = XmppConnection(socket: fakeSocket);
      conn.setConnectionSettings(ConnectionSettings(
          jid: JID.fromString("polynomdivision@test.server"),
          password: "aaaa",
          useDirectTLS: true,
          allowPlainAuth: true
      ));
      conn.registerManager(RosterManager());
      conn.registerManager(DiscoManager());
      conn.registerManager(PresenceManager());

      await conn.connect(srvQuery: srvQueryStub);
      await Future.delayed(const Duration(seconds: 3), () {
          expect(fakeSocket.getState(), 5);
      });
  });

  test("Test a failed SASL auth", () async {
      final fakeSocket = StubTCPSocket(
        play: [
          Expectation(
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "to": "test.server",
                "xml:lang": "en"
              },
              closeTag: false
            ),
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "from": "test.server",
                "xml:lang": "en"
              },
              closeTag: false,
              children: [
                XMLNode.xmlns(
                  tag: "stream:features",
                  xmlns: "http://etherx.jabber.org/streams",
                  children: [
                    XMLNode.xmlns(
                      tag: "mechanisms",
                      xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
                      children: [
                        XMLNode(tag: "mechanism", text: "PLAIN")
                      ]
                    )
                  ]
                )
              ]
            )
          ),
          Expectation(XMLNode.xmlns(
              tag: "auth",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              attributes: {
                "mechanism": "PLAIN"
              },
              text: "AHBvbHlub21kaXZpc2lvbgBhYWFh"
            ),
            XMLNode.xmlns(
              tag: "failure",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              children: [
                XMLNode(tag: "not-authorized")
              ]
            )
          )
        ]
      );
      bool receivedEvent = false;
      final XmppConnection conn = XmppConnection(socket: fakeSocket);
      conn.setConnectionSettings(ConnectionSettings(
          jid: JID.fromString("polynomdivision@test.server"),
          password: "aaaa",
          useDirectTLS: true,
          allowPlainAuth: true
      ));
      conn.registerManager(PresenceManager());
      conn.registerManager(RosterManager());
      conn.registerManager(DiscoManager());

      conn.asBroadcastStream().listen((event) {
          if (event is AuthenticationFailedEvent && event.saslError == "not-authorized") {
            receivedEvent = true;
          }
      });

      await conn.connect(srvQuery: srvQueryStub);
      await Future.delayed(const Duration(seconds: 3), () {
          expect(receivedEvent, true);
      });
  });

  test("Test another failed SASL auth", () async {
      final fakeSocket = StubTCPSocket(
        play: [
          Expectation(
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "to": "test.server",
                "xml:lang": "en"
              },
              closeTag: false
            ),
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "from": "test.server",
                "xml:lang": "en"
              },
              closeTag: false,
              children: [
                XMLNode.xmlns(
                  tag: "stream:features",
                  xmlns: "http://etherx.jabber.org/streams",
                  children: [
                    XMLNode.xmlns(
                      tag: "mechanisms",
                      xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
                      children: [
                        XMLNode(tag: "mechanism", text: "PLAIN")
                      ]
                    )
                  ]
                )
              ]
            )
          ),
          Expectation(XMLNode.xmlns(
              tag: "auth",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              attributes: {
                "mechanism": "PLAIN"
              },
              text: "AHBvbHlub21kaXZpc2lvbgBhYWFh"
            ),
            XMLNode.xmlns(
              tag: "failure",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              children: [
                XMLNode(tag: "mechanism-too-weak")
              ]
            )
          )
        ]
      );
      bool receivedEvent = false;
      final XmppConnection conn = XmppConnection(socket: fakeSocket);
      conn.setConnectionSettings(ConnectionSettings(
          jid: JID.fromString("polynomdivision@test.server"),
          password: "aaaa",
          useDirectTLS: true,
          allowPlainAuth: true
      ));
      conn.registerManager(PresenceManager());
      conn.registerManager(RosterManager());
      conn.registerManager(DiscoManager());

      conn.asBroadcastStream().listen((event) {
          if (event is AuthenticationFailedEvent && event.saslError == "mechanism-too-weak") {
            receivedEvent = true;
          }
      });

      await conn.connect(srvQuery: srvQueryStub);
      await Future.delayed(const Duration(seconds: 3), () {
          expect(receivedEvent, true);
      });
  });

  test("Test choosing SCRAM-SHA-1", () async {
      final fakeSocket = StubTCPSocket(
        play: [
          Expectation(
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "to": "test.server",
                "xml:lang": "en"
              },
              closeTag: false
            ),
            XMLNode(
              tag: "stream:stream",
              attributes: {
                "xmlns": "jabber:client",
                "version": "1.0",
                "xmlns:stream": "http://etherx.jabber.org/streams",
                "from": "test.server",
                "xml:lang": "en"
              },
              closeTag: false,
              children: [
                XMLNode.xmlns(
                  tag: "stream:features",
                  xmlns: "http://etherx.jabber.org/streams",
                  children: [
                    XMLNode.xmlns(
                      tag: "mechanisms",
                      xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
                      children: [
                        XMLNode(tag: "mechanism", text: "PLAIN"),
                        XMLNode(tag: "mechanism", text: "SCRAM-SHA-1")
                      ]
                    )
                  ]
                )
              ]
            )
          ),
          Expectation(XMLNode.xmlns(
              tag: "auth",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              attributes: {
                "mechanism": "SCRAM-SHA-1"
              },
              text: "..."
            ),
            XMLNode.xmlns(
              tag: "challenge",
              xmlns: "urn:ietf:params:xml:ns:xmpp-sasl",
              attributes: {
                "mechanism": "SCRAM-SHA-1"
              },
              text: "cj02ZDQ0MmI1ZDllNTFhNzQwZjM2OWUzZGNlY2YzMTc4ZWMxMmIzOTg1YmJkNGE4ZTZmODE0YjQyMmFiNzY2NTczLHM9UVNYQ1IrUTZzZWs4YmY5MixpPTQwOTY="
            ),
            justCheckAttributes: {
              "mechanism": "SCRAM-SHA-1"
            }
          )
        ]
      );
      final XmppConnection conn = XmppConnection(socket: fakeSocket);
      conn.setConnectionSettings(ConnectionSettings(
          jid: JID.fromString("polynomdivision@test.server"),
          password: "aaaa",
          useDirectTLS: true,
          allowPlainAuth: false
      ));
      conn.registerManager(RosterManager());
      conn.registerManager(DiscoManager());
      conn.registerManager(PresenceManager());

      await conn.connect(srvQuery: srvQueryStub);
      await Future.delayed(const Duration(seconds: 3), () {
          expect(fakeSocket.getState(), 2);
      });
  });

  group("Test roster pushes", () {
      test("Test for a CVE-2015-8688 style vulnerability", () async {
          bool eventTriggered = false;
          final roster = RosterManager();
          roster.register(XmppManagerAttributes(
              sendStanza: (_, { bool addFrom = true, bool addId = true}) async => XMLNode(tag: "hallo"),
              sendEvent: (event) {
                eventTriggered = true;
              },
              sendNonza: (_) {},
              sendRawXml: (_) {},
              getConnectionSettings: () => ConnectionSettings(
                jid: JID.fromString("some.user@example.server"),
                password: "password",
                useDirectTLS: true,
                allowPlainAuth: false,
              ),
              getManagerById: (_) => null,
              isStreamFeatureSupported: (_) => false,
              isFeatureSupported: (_) => false,
              getFullJID: () => JID.fromString("some.user@example.server/aaaaa")
          ));

          // NOTE: Based on https://gultsch.de/gajim_roster_push_and_message_interception.html
          // NOTE: Added a from attribute as a server would add it itself.
          final maliciousStanza = Stanza.fromXMLNode(XMLNode.fromString("<iq type=\"set\" from=\"eve@siacs.eu/bbbbb\" to=\"some.user@example.server/aaaaa\"><query xmlns='jabber:iq:roster'><item subscription=\"both\" jid=\"eve@siacs.eu\" name=\"Bob\" /></query></iq>"));
          await Future.forEach(
            roster.getStanzaHandlers(),
            (StanzaHandler handler) async {
              if (handler.matches(maliciousStanza)) {
                await handler.callback(maliciousStanza);
              }
            }
          );

          expect(eventTriggered, false, reason: "Was able to inject a malicious roster push");
      });
      test("The manager should accept pushes from our bare jid", () async {
          final result = await testRosterManager("test.user@server.example", "aaaaa", "<iq from='test.user@server.example' type='result' id='82c2aa1e-cac3-4f62-9e1f-bbe6b057daf3' to='test.user@server.example/aaaaa' xmlns='jabber:client'><query ver='64' xmlns='jabber:iq:roster'><item jid='some.other.user@server.example' subscription='to' /></query></iq>");
          expect(result, true, reason: "Roster pushes from our bare JID should be accepted");
      });
      test("The manager should accept pushes from a jid that, if the resource is stripped, is our bare jid", () async {
          final result1 = await testRosterManager("test.user@server.example", "aaaaa", "<iq from='test.user@server.example/aaaaa' type='result' id='82c2aa1e-cac3-4f62-9e1f-bbe6b057daf3' to='test.user@server.example/aaaaa' xmlns='jabber:client'><query ver='64' xmlns='jabber:iq:roster'><item jid='some.other.user@server.example' subscription='to' /></query></iq>");
          expect(result1, true, reason: "Roster pushes should be accepted if the bare JIDs are the same");

          final result2 = await testRosterManager("test.user@server.example", "aaaaa", "<iq from='test.user@server.example/bbbbb' type='result' id='82c2aa1e-cac3-4f62-9e1f-bbe6b057daf3' to='test.user@server.example/aaaaa' xmlns='jabber:client'><query ver='64' xmlns='jabber:iq:roster'><item jid='some.other.user@server.example' subscription='to' /></query></iq>");
          expect(result2, true, reason: "Roster pushes should be accepted if the bare JIDs are the same");
      });
  });
}
