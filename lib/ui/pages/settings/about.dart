import "package:moxxyv2/ui/constants.dart";
import "package:moxxyv2/ui/widgets/topbar.dart";

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

// TODO: Include license text?
// TODO: Maybe include the version number
class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({ Key? key }) : super(key: key);

  void _openUrl(String url) async {
    if (!await launch(url)) {
      // TODO: Show a popup to copy the url
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BorderlessTopbar.simple(title: "About"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: paddingVeryLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              width: 200, height: 200
            ),
            const Text(
              "moxxy",
              style: TextStyle(
                fontSize: 40
              )
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "An experimental XMPP client that is beautiful, modern and easy to use",
                style: TextStyle(
                  fontSize: 15
                )
              )
            ),
            const Text("Licensed under GPL3"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                child: const Text("View source code"),
                onPressed: () => _openUrl("https://github.com/PapaTutuWawa/moxxyv2")
              )
            ) 
          ]
        )
      )
    );
  }
}
