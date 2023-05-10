import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:skating_app/api/websocket.dart';
import 'package:uuid/uuid.dart';
import '../../api/config.dart';
import '../../api/messages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../swatch.dart';

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

// Define a StatefulWidget for displaying private messages
class PrivateMessage extends StatefulWidget {
  // Constructor takes an index and a channel as arguments
  const PrivateMessage(
      {Key? key, required this.index, required this.channel, this.user})
      : super(key: key);
  final int index;
  final String channel;
  final Map<String, dynamic>? user;

  // Create and return a state for the widget
  @override
  State<PrivateMessage> createState() => _PrivateMessage();
}

// Define the state for PrivateMessage widget
class _PrivateMessage extends State<PrivateMessage> {
  // Initialize a list to store messages
  final List<types.Message> _messages = [];
  // Initialize a page number for pagination
  int _page = 0;
  // Set a loading flag to show/hide loading indicator
  bool loading = false;
  // Initialize a stream subscription
  late StreamSubscription subscription;
  final _user = const types.User(id: "82091008-a484-4a89-ae75-a22bf8d6f3ac");

  @override
  void initState() {
    super.initState();
    // Load initial messages
    loadMessages();
    // Join the channel using websockets
    getIt<WebSocketConnection>().socket.emit("joinChannel", [widget.channel]);
    // Subscribe to the websocket stream
    subscription = getIt<WebSocketConnection>()
        .stream
        .listen((data) => {updateMessages(data)});
  }

  List<types.User> users = [types.User(id: const Uuid().v1())];
  types.User getUser(String user) {
    for (var i = 0; i < users.length; i++) {
      if (users[i].id == user) {
        return users[i];
      }
    }
    var newUser = types.User(id: user);
    users.add(newUser);
    return newUser;
  }

  // Function to update messages when new messages arrive
  void updateMessages(Map<String, dynamic> data) {
    // If the message is for the current channel
    if (data["channel"] == widget.channel) {
      print("ITS A MATCH!");
      // Add the new message to the beginning of the list
      setState(() {
        _messages.insert(
            0,
            types.TextMessage(
              author: getUser(data["sender"]),
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: const Uuid().v1(),
              text: data["content"],
            ));
      });
    }
  }

  Future<void> loadMessages() async {
    if (loading) {
      return;
    }

    loading = true;

    final messagesRaw = await getMessages(_page, widget.channel);
    List<types.Message> messages = [];
    for (int i = 0; i < messagesRaw.length; i++) {
      dynamic message = messagesRaw[i];
      messages.add(types.TextMessage(
        // Create new message
        author: getUser(message["sender"]), // Set author of message
        createdAt: DateTime.parse(message["date_sent"])
            .millisecondsSinceEpoch, // Get time
        id: const Uuid().v1(), // Generate random debug user id
        text: message["content"], // Set message content
      ));
    }
    setState(() {
      _messages.addAll(messages);
      _page++;
      loading = false;
    });
  }

  Future<void> _loadMoreMessages() async {
    print("eeee");
    final nextPage = _page + 1;
    final messagesRaw = await getMessages(nextPage, widget.channel);
    List<types.Message> messages = [];
    for (int i = 0; i < messagesRaw.length; i++) {
      dynamic message = messagesRaw[i];
      messages.add(types.TextMessage(
        // Create new message
        author: getUser(message["sender"]), // Set author of message
        createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
        id: const Uuid().v1(), // Generate random debug user id
        text: message["content"], // Set message content
      ));
    }
    setState(() {
      _messages.addAll(messages);
      _page = nextPage;
    });
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    ChatL10n locale;
    switch (AppLocalizations.of(context)!.localeName) {
      case "pl":
        locale = const ChatL10nPl();
        break;
      default:
        locale = const ChatL10nEn();
    }
    return Scaffold(
      appBar: AppBar(
        // Create appBar
        leadingWidth: 48, // Remove extra leading space
        centerTitle: false, // Align title to left
        title: Row(children: [
          //Create title as row
          widget.user == null || widget.user?["avatar"] == null
              // If there is no cached user information or avatar image, use a default image
              ? CircleAvatar(
                  radius: 15, // Set the radius of the circular avatar image
                  child: ClipOval(
                    child: Image.asset("assets/placeholders/default.png"),
                  ),
                )
              // If there is cached user information and an avatar image, use the cached image
              : //Flexible(
              CachedNetworkImage(
                  height: 40,
                  width: 40,
                  imageUrl: '${Config.uri}/image/${widget.user!["avatar"]}',
                  httpHeaders: const {"thumbnail": "true"},
                  placeholder: (context, url) => CircleAvatar(
                        // Set the radius of the circular avatar image
                        child: ClipOval(
                          child: Image.asset("assets/placeholders/default.png"),
                        ),
                      ),
                  imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape
                              .circle, // Set the shape of the container to a circle
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.fill),
                        ),
                      )),
          //),
          //Flexible(
          //flex: 6,
          Padding(
              // Create basic padding to space from avatar
              padding: const EdgeInsets.all(8),
              child: Column(
                // Create column of text
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Align to the left instead of center
                children: [
                  Text(
                    //Username Text
                    widget.user?["username"] ??
                        AppLocalizations.of(context)!.username,
                    style: TextStyle(fontSize: 16, color: swatch[700]),
                  ),
                  Text(
                    // Last active text
                    AppLocalizations.of(context)!.activityOnline,
                    style: TextStyle(fontSize: 12, color: swatch[600]),
                  )
                ],
              )) //),
        ]),
      ),
      body: Chat(
        l10n: locale, // Set locale
        // Create basic chat widget
        messages: _messages, // Set messages to message variable defined above
        onSendPressed: _handleSendPressed,
        user: _user, // Set user to user id
        theme: DefaultChatTheme(
            backgroundColor: swatch[501]!,
            secondaryColor: swatch[51]!,
            inputBackgroundColor: swatch[51]!,
            inputTextColor: swatch[800]!,
            dateDividerTextStyle: TextStyle(
                color: swatch[600],
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.333),
            inputMargin: const EdgeInsets.only(
                left: 8, right: 8, bottom: 8), // Add margins to text input
            inputBorderRadius: const BorderRadius.all(
                Radius.circular(24))), // Make input rounded corners
        onEndReached: () => _loadMoreMessages(),
      ),
    );
  }

  void _addMessage(types.Message message) {
    // Define addMessage function
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    try {
      // Define handleSendPressed function
      final textMessage = types.TextMessage(
        // Create new message
        author: _user, // Set author of message
        createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
        id: const Uuid().v1(), // Generate random debug user id
        text: message.text, // Set message content
      );
      _addMessage(textMessage); // Run addMessage function
      print(await postMessage(widget.channel, message.text, null));
    } catch (e) {
      final errorMessage = types.SystemMessage(
        // Create new message
        createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
        id: const Uuid().v1(), // Generate random debug user id
        text: "Message Failed To Send", // Set message content
      );
      _addMessage(errorMessage);
      print("An error Occurred $e");
    }
  }

  @override
  void dispose() {
    try {
      subscription.cancel(); // Stop listening to new messages
    } catch (e) {
      print(e);
    }
    super.dispose();
  }
}
