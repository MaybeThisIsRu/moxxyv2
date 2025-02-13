import json

def getFirstValue(obj):
    return list(obj.values())[0]

def renderServer(obj):
    return "\tXMPPProvider(\"{}\", \"{}\", \"{}\")".format(
        obj["jid"],
        getFirstValue(obj["website"]),
        getFirstValue(obj["legalNotice"])
    )

def main():
    with open("thirdparty/xmpp-providers/providers-A.json", "r") as f:
        providers = json.loads(f.read())

    generated = '''// Generated by generate_providers.py
import "dart:collection";
import "package:moxxyv2/data/providers.dart";

const List<XMPPProvider> xmppProviderList = [
{}
];
'''.format(",\n".join([
    renderServer(obj) for obj in providers
]));

    with open("lib/ui/data/generated/providers.dart", "w") as f:
        f.write(generated)

if __name__ == '__main__':
    main()
