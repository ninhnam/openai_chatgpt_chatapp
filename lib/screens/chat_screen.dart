import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ChatGPT/constants/constants.dart';
import 'package:ChatGPT/models/chat_model.dart';
import 'package:ChatGPT/providers/models_provider.dart';
import 'package:ChatGPT/services/api_services.dart';
import 'package:ChatGPT/services/assets_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ChatGPT/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/conversation_provider.dart';
import '../services/history_services.dart';
import '../services/services.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  bool isSpeaking = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  List<GlobalKey<ChatWidgetState>> _childWidgetKeys = [];

  void _toggleChildWidget() {
    _childWidgetKeys.forEach((key) {
      key.currentState?.setFalse();
    });
  }

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    _childWidgetKeys = List.generate(100, (_) => GlobalKey<ChatWidgetState>());
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    var conversationProvider = Provider.of<ConversationProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.openaiLogo),
          ),
          title: Text(
            "ChatGPT",
            style: TextStyle(color: welcomButtomColor),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await Services.showModalSheet(
                    context: context,
                    chatProvider: chatProvider,
                    conversationProvider: conversationProvider);
              },
              icon: Icon(Icons.more_vert_rounded, color: textHeaderColor),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                    controller: _listScrollController,
                    itemCount:
                        chatProvider.getChatList.length, //chatList.length,
                    itemBuilder: (context, index) {
                      return ChatWidget(
                        key: _childWidgetKeys[index],
                        changeSpeaking: changeSpeaking,
                        isSpeaking: isSpeaking,
                        msg: chatProvider
                            .getChatList[index].msg, // chatList[index].msg,
                        chatIndex: chatProvider.getChatList[index]
                            .chatIndex, //chatList[index].chatIndex,
                        shouldAnimate:
                            chatProvider.getChatList.length - 1 == index,
                      );
                    }),
              ),
              if (_isTyping) ...[
                SpinKitThreeBounce(
                  color: textHeaderColor,
                  size: 18,
                ),
              ],
              const SizedBox(
                height: 15,
              ),
              Material(
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          style: TextStyle(color: textHeaderColor),
                          controller: textEditingController,
                          onSubmitted: (value) async {
                            await sendMessageFCT(
                                conversationProvider: conversationProvider,
                                modelsProvider: modelsProvider,
                                chatProvider: chatProvider);
                          },
                          decoration: InputDecoration.collapsed(
                              hintText: "How can I help you",
                              hintStyle: TextStyle(color: textInTextfield)),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            await sendMessageFCT(
                                modelsProvider: modelsProvider,
                                chatProvider: chatProvider,
                                conversationProvider: conversationProvider);
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.green[700],
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider,
      required ConversationProvider conversationProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You can't send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);

        HistoryService.addChatToConversation(
            chat: ChatModel(msg: msg, chatIndex: 0),
            conversation: conversationProvider.getConversation!);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg,
          chosenModelId: modelsProvider.getCurrentModel,
          conversationModel: conversationProvider.getConversation!);
      // chatList.addAll(await ApiService.sendMessage(
      //   message: textEditingController.text,
      //   modelId: modelsProvider.getCurrentModel,
      // ));
      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
      // chatProvider.getChatList.forEach((element) {
      //   print(element.toString());
      // });
    }
  }

  void changeSpeaking() {
    setState(() {
      isSpeaking = !isSpeaking;
    });
    _toggleChildWidget();
  }
}
