import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openai_chatgpt_chatapp/models/conversation_model.dart';
import 'package:openai_chatgpt_chatapp/providers/conversation_provider.dart';
import 'package:openai_chatgpt_chatapp/screens/history_screen.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../database/database.dart';
import '../providers/chat_provider.dart';

class Services {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<void> showModalSheet(
      {required BuildContext context,
      required ChatProvider chatProvider,
      required ConversationProvider conversationProvider}) async {
    double screenWidth = MediaQuery.of(context).size.width;

    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        backgroundColor: scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.green,
                  ),
                  child: TextButton(
                    onPressed: () {
                      chatProvider.generateNewChat(conversationProvider);
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: Text(
                        "New Chat",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                Container(
                  width: screenWidth - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.blueAccent[400],
                  ),
                  child: TextButton(
                    onPressed: () {
                      // final route = MaterialPageRoute(
                      //     builder: (context) => HistoryScreen());
                      // Navigator.push(context, route);
                      Navigator.pushNamed(context, '/history-screen');
                      Navigator.pushNamed(
                        context,
                        '/history-screen',
                        arguments: {'prevPage': '/chat-screen'},
                      );
                    },
                    child: Center(
                      child: Text(
                        "History",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static Future<void> showEditConvModal(
      {required BuildContext context,
      required ConversationModel conversation,
      required Function loadData}) async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[800],
        isScrollControlled: true,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Delete '${conversation.name}'",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              Container(
                // padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Padding(padding: EdgeInsets.only(left: 20)),
                    Expanded(
                        child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green[800]),
                        onPressed: () async {
                          await _databaseHelper.deleteConv(conversation);
                          Navigator.of(context).pop();
                          await loadData();
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    )),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    Expanded(
                        child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: Colors.pink[700]),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    )),
                    const Padding(padding: EdgeInsets.only(right: 20)),
                  ],
                ),
              )
              //ok button
              ,
              SizedBox(
                height: 100,
              )
            ],
          );
        });
  }
}
