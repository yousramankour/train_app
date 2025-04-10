import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Importer easy_localization

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<MessageScreen> {
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
      backgroundColor:
          Theme.of(
            context,
          ).scaffoldBackgroundColor, // Utiliser la couleur de fond du thème
      appBar: AppBar(
        title: Text("chat".tr()), // Traduction du titre
        backgroundColor:
            Theme.of(context)
                .appBarTheme
                .backgroundColor, // Utiliser la couleur de l'AppBar du thème
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
                      color:
                          Theme.of(context)
                              .inputDecorationTheme
                              .fillColor, // Couleur de fond du champ de texte
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
                              hintText:
                                  "type_message"
                                      .tr(), // Traduction pour le hint
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
                  backgroundColor:
                      Theme.of(
                        context,
                      ).primaryColor, // Utiliser la couleur principale du thème
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

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isMe
                  ? Theme.of(context)
                      .primaryColor // Utiliser la couleur principale du thème pour le message de l'utilisateur
                  : Theme.of(
                    context,
                  ).cardColor, // Couleur de la carte pour les messages reçus
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
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color:
                    isMe
                        ? Colors
                            .white // Texte en blanc pour les messages envoyés par l'utilisateur
                        : Colors.black, // Texte en noir pour les messages reçus
              ),
            ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color:
                    isMe
                        ? Colors
                            .white60 // Légèrement transparent pour les messages envoyés par l'utilisateur
                        : Colors
                            .black54, // Légèrement transparent pour les messages reçus
              ),
            ),
          ],
        ),
      ),
    );
  }
}
