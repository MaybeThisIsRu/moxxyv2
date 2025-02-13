import "dart:collection";

import "package:moxxyv2/shared/models/conversation.dart";
import "package:moxxyv2/ui/redux/conversation/actions.dart";

HashMap<String, Conversation> conversationReducer(HashMap<String, Conversation> state, dynamic action) {
  if (action is AddConversationAction) {
    state[action.conversation.jid] = action.conversation;
  } else if (action is AddMultipleConversationsAction) {
    for (var c in action.conversations) {
      state[c.jid] = c;
    }
  } else if (action is UpdateConversationAction) {
    state[action.conversation.jid] = action.conversation;
  } else if (action is CloseConversationAction) {
    final c = state[action.jid]!;
    state[action.jid] = c.copyWith(open: false);
  }
  
  return state;
}
