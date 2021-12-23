import 'package:flutter/material.dart';
import 'package:moxxyv2/ui/widgets/topbar.dart';
import 'package:moxxyv2/ui/widgets/conversation.dart';
import 'package:moxxyv2/models/conversation.dart';
import 'package:moxxyv2/redux/state.dart';
import 'package:moxxyv2/redux/conversations/actions.dart';
import 'package:moxxyv2/ui/pages/conversation.dart';
import 'package:moxxyv2/repositories/conversations.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:get_it/get_it.dart';

typedef AddConversationFunction = void Function(Conversation conversation);

class _NewConversationViewModel {
  final AddConversationFunction addConversation;

  _NewConversationViewModel({ required this.addConversation });
}

class NewConversationPage extends StatelessWidget {
  void _addNewContact(_NewConversationViewModel viewModel, BuildContext context, String jid) {
    Conversation? conversation = GetIt.I.get<ConversationRepository>().getConversation(jid);

    if (conversation == null) {
      // TODO
      // TODO: Install a middleware to make sure that the conversation gets added to the
      //       repository. Also handle updates
      conversation = Conversation(
        title: jid,
        jid: jid,
        lastMessageBody: "",
        avatarUrl: ""
      );
      GetIt.I.get<ConversationRepository>().setConversation(conversation);
    }
    viewModel.addConversation(conversation);
    
    // TODO: Pass arguments
    // TODO: Make sure that no conversation can be added twice
    Navigator.pushNamedAndRemoveUntil(context, "/conversation", ModalRoute.withName("/conversations"), arguments: ConversationPageArguments(jid: jid));
  }
  
  @override
  Widget build(BuildContext context) {
    var conversations = GetIt.I.get<ConversationRepository>().getAllConversations();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: BorderlessTopbar(
          children: [
            BackButton(),
            Text(
              "Start new chat",
              style: TextStyle(
                fontSize: 17
              )
            )
          ]
        )
      ),
      body: StoreConnector<MoxxyState, _NewConversationViewModel>(
        converter: (store) => _NewConversationViewModel(
          addConversation: (c) => store.dispatch(
            AddConversationAction(
              title: c.title,
              avatarUrl: c.avatarUrl,
              lastMessageBody: c.lastMessageBody,
              jid: c.jid
            )
          )
        ),
        builder: (context, viewModel) => ListView.builder(
          itemCount: conversations.length + 2,
          itemBuilder: (context, index) {
            switch(index) {
              case 0: {
                return InkWell(
                  onTap: () => Navigator.pushNamed(context, "/new_conversation/add_contact"),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          child: Icon(Icons.person_add),
                          radius: 35.0
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Add contact",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold
                          )
                        )
                      )
                    ]
                  )
                );
              }
              break;
              case 1: {
                return Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        child: Icon(Icons.group_add),
                        radius: 35.0
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Create groupchat",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ]
                );
              }
              break;
              default: {
                Conversation item = conversations[index - 2];
                return InkWell(
                  onTap: () => this._addNewContact(viewModel, context, item.jid),
                  child: ConversationsListRow(item.avatarUrl, item.title, item.jid)
                );
              }
              break;
            }
          }
        )
      )
    );
  }
}
