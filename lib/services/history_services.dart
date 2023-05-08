import 'package:openai_chatgpt_chatapp/models/chat_model.dart';
import 'package:openai_chatgpt_chatapp/models/conversation_model.dart';

import '../database/database.dart';
import '../providers/conversation_provider.dart';

class HistoryService {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static void createNewChat(
      {required ConversationProvider conversationProvider}) async {
    ConversationModel? endConv = await _databaseHelper.getEndElemConversation();
    int newIdConv;
    if (endConv == null) {
      newIdConv = 1;
    } else {
      newIdConv = endConv.id! + 2;
    }
    ConversationModel newConversation = await _databaseHelper
        .addConv(ConversationModel(name: "New Chat ${newIdConv}"));
    newConversation.id = newIdConv - 1;
    conversationProvider.changeCurrentConversation(
        conversationModel: newConversation);
  }

  static void addChatToConversation(
      {required ChatModel chat,
      required ConversationModel conversation}) async {
    chat.conversationId = conversation.id;
    await _databaseHelper.addChat(chat);
  }
}