import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _messages.insert(0, {
          "text": _controller.text,
          "isMe": true,
          "time": DateFormat(
            'HH:mm',
          ).format(DateTime.now()), // ✅ Ajout de l'heure
        });
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Fond blanc
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Color(0xFFACDBF1), // ✅ Couleur de ton projet
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  message: _messages[index]["text"],
                  isMe: _messages[index]["isMe"],
                  time: _messages[index]["time"],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.emoji_emotions, color: Colors.grey),
                          onPressed: () {}, // ✅ Ajout d’un bouton emoji
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFFACDBF1),
                  radius: 25,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  ChatBubble({required this.message, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFFACDBF1) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: isMe ? Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(15),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message, style: TextStyle(fontSize: 16, color: Colors.black)),
            SizedBox(height: 5),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
