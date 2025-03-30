
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:ilays_team/AI_ask/constant.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: ApiConstants.openAIKey,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 15)),
    enableLog: true,
  );

  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'hamza',
    lastName: 'Abdiaziz',
  );
  final ChatUser _gptChatUser = ChatUser(
    id: '2',
    firstName: 'chat',
    lastName: 'gpt',
  );
  final List<ChatMessage> _messages = <ChatMessage>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 166, 126, 1),
        title: Text("AI Ask", style: TextStyle(color: Colors.white)),
      ),
      body: DashChat(
        currentUser: _currentUser,
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.black,
          containerColor: Color.fromRGBO(0, 166, 126, 1),
          textColor: Colors.white,
        ),
        onSend: (ChatMessage m) {
          // Handle the send action here
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });

    final List<Messages> messagesHistory =
        _messages.reversed.map((m) {
          if (m.user == _currentUser) {
            return Messages(role: Role.user, content: m.text);
          } else {
            return Messages(role: Role.assistant, content: m.text);
          }
        }).toList();
    final request = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: messagesHistory.map((msg) => msg.toJson()).toList(),
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _gptChatUser,
              createdAt: DateTime.now(),
              text: element.message!.content,
            ),
          );
        });
      }
    }
  }
}
