import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

class PrivateMessage extends StatefulWidget {
  // Create HomePage Class
  const PrivateMessage({Key? key, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  @override
  State<PrivateMessage> createState() =>
      _PrivateMessage(); //Create state for widget
}

class _PrivateMessage extends State<PrivateMessage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Create appBar
        leadingWidth: 48, // Remove extra leading space
        centerTitle: false, // Align title to left
        title: Row(children: [
          //Create title as row
          const CircleAvatar(
            // Create a circular avatar icon
            radius: 15, //Set radius to 15
            backgroundImage: AssetImage(
                "assets/placeholders/150.png"), // Set avatar to placeholder images
          ),
          Padding(
              // Create basic padding to space from avatar
              padding: const EdgeInsets.all(8),
              child: Column(
                // Create column of text
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Align to the left instead of center
                children: const [
                  Text(
                    //Username Text
                    "Username",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    // Last active text
                    "Online",
                    style: TextStyle(fontSize: 12, color: Color(0xffbbbbbb)),
                  )
                ],
              ))
        ]),
      ),
      body: Chat(
        // Create basic chat widget
        messages: _messages, // Set messages to message variable defined above
        onSendPressed: _handleSendPressed,
        user: _user, // Set user to user id
        theme: const DarkChatTheme(
            inputMargin: EdgeInsets.only(
                left: 8, right: 8, bottom: 8), // Add margins to text input
            inputBorderRadius: BorderRadius.all(
                Radius.circular(24))), // Make input rounded corners
      ),
    );
  }

  void _addMessage(types.Message message) {
    // Define addMessage function
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    // Define handleSendPressed function
    final textMessage = types.TextMessage(
      // Create new message
      author: _user, // Set author of message
      createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
      id: const Uuid().v1(), // Generate random debug user id
      text: message.text, // Set message content
    );
    _addMessage(textMessage); // Run addMessage function
  }
}
