import "package:equatable/equatable.dart";

class Conversation extends Equatable {
  final String title;
  final String lastMessageBody;
  final String avatarUrl;
  final String jid;
  final int id;
  final int unreadCounter;
  final int lastChangeTimestamp; // NOTE: In milliseconds since Epoch or -1 if none has ever happened
  // TODO: Maybe have a model for this, but this should be enough
  final List<String> sharedMediaPaths;
  final bool open;

  const Conversation({ required this.title, required this.lastMessageBody, required this.avatarUrl, required this.jid, required this.unreadCounter, required this.lastChangeTimestamp, required this.sharedMediaPaths, required this.id, required this.open });

  // TODO: The title and avatarUrl can also change
  Conversation copyWith({ String? lastMessageBody, int? unreadCounter, int unreadDelta = 0, List<String>? sharedMediaPaths, int? lastChangeTimestamp, bool? open }) {
    return Conversation(
      title: title,
      lastMessageBody: lastMessageBody ?? this.lastMessageBody,
      avatarUrl: avatarUrl,
      jid: jid,
      unreadCounter: (unreadCounter ?? this.unreadCounter) + unreadDelta,
      sharedMediaPaths: sharedMediaPaths ?? this.sharedMediaPaths,
      lastChangeTimestamp: lastChangeTimestamp ?? this.lastChangeTimestamp,
      open: open ?? this.open,
      id: id
    );
  }

  Conversation.fromJson(Map<String, dynamic> json)
  : title = json["title"],
  lastMessageBody = json["lastMessageBody"],
  avatarUrl = json["avatarUrl"],
  jid = json["jid"],
  unreadCounter = json["unreadCounter"],
  sharedMediaPaths = List<String>.from(json["sharedMediaPaths"]),
  lastChangeTimestamp = json["lastChangeTimestamp"],
  open = json["open"],
  id = json["id"];

  Map<String, dynamic> toJson() => {
    "title": title,
    "lastMessageBody": lastMessageBody,
    "jid": jid,
    "avatarUrl": avatarUrl,
    "unreadCounter": unreadCounter,
    "sharedMediaPaths": sharedMediaPaths,
    "lastChangeTimestamp": lastChangeTimestamp,
    "open": open,
    "id": id
  };
  
  @override
  bool get stringify => true;
  
  @override
  List<Object> get props => [ title, lastMessageBody, avatarUrl, id, jid, unreadCounter, lastChangeTimestamp, open ];
}
