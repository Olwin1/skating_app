import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/websocket.dart';
import 'package:patinka/common_logger.dart';
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
      {Key? key,
      required this.index,
      required this.channel,
      this.user,
      required this.currentUser})
      : super(key: key);
  final int index;
  final String channel;
  final Map<String, dynamic>? user;
  final String currentUser;

  // Create and return a state for the widget
  @override
  State<PrivateMessage> createState() => _PrivateMessage();
}

// Define the state for PrivateMessage widget
class _PrivateMessage extends State<PrivateMessage> {
  bool sending = false;
  // Initialize a list to store messages
  final List<types.Message> _messages = [];
  // Initialize a page number for pagination
  int _page = 0;
  // Set a loading flag to show/hide loading indicator
  bool loading = false;
  // Initialize a stream subscription
  late StreamSubscription subscription;
  TextEditingController controller = TextEditingController();

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
        .listen((data) => updateMessages(data));
  }

  Widget _messagesSkeleton() {
    Widget child(bool lalign, double width) {
      return Shimmer.fromColors(
          baseColor: const Color(0x66000000),
          highlightColor: const Color(0xff444444),
          child: Container(
              width: 100,
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                  alignment:
                      lalign ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xb5000000),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    height: 42,
                    width: width,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8), // Add padding so doesn't touch edges
                    padding: const EdgeInsets.symmetric(
                        vertical: 8), // Add padding so doesn't touch edges
                  ))));
    }

    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            child(true, 100),
            child(false, 150),
            child(true, 100),
            child(false, 100),
            child(true, 250),
            child(false, 100),
            child(true, 80),
            child(false, 100),
            child(true, 300),
            child(false, 100),
            child(true, 200),
            child(false, 100),
          ],
        ));
  }

  List<types.User> users = [];
  types.User getUser(String userId, String username) {
    for (var i = 0; i < users.length; i++) {
      if (users[i].id == userId) {
        commonLogger.d(users[i]);
        return users[i];
      }
    }
    commonLogger.d("created");
    var newUser = types.User(id: userId, firstName: username);
    users.add(newUser);
    return newUser;
  }

  // Function to update messages when new messages arrive
  void updateMessages(Map<String, dynamic> data) {
    // If the message is for the current channel
    if (data["channel"] == widget.channel) {
      commonLogger.d("ITS A MATCH!");
      // Add the new message to the beginning of the list
      mounted
          ? setState(() {
              _messages.insert(
                  0,
                  types.TextMessage(
                    author: getUser(data["sender"], "ss"),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    id: const Uuid().v1(),
                    text: data["content"],
                  ));
            })
          : null;
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
        author: getUser(message["sender"], "ss"), // Set author of message
        createdAt: DateTime.parse(message["date_sent"])
            .millisecondsSinceEpoch, // Get time
        id: message["_id"], // Generate random debug user id
        text: message["content"], // Set message content
      ));
    }
    mounted
        ? setState(() {
            _messages.addAll(messages);
            _page++;
            loading = false;
          })
        : null;
  }

  Future<void> _loadMoreMessages() async {
    commonLogger.v("Loading more messages");
    final nextPage = _page + 1;
    final messagesRaw = await getMessages(nextPage, widget.channel);
    List<types.Message> messages = [];
    for (int i = 0; i < messagesRaw.length; i++) {
      dynamic message = messagesRaw[i];
      messages.add(types.TextMessage(
        // Create new message
        author: getUser(message["sender"], "ss"), // Set author of message
        createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
        id: message["_id"], // Generate random debug user id
        text: message["content"], // Set message content
      ));
    }
    mounted
        ? setState(() {
            _messages.addAll(messages);
            _page = nextPage;
          })
        : null;
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
                    imageUrl:
                        '${Config.uri}/image/thumbnail/${widget.user!["avatar"]}',
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: const Color(0x66000000),
                        highlightColor: const Color(0xff444444),
                        child: CircleAvatar(
                          // Create a circular avatar icon
                          radius: 36, // Set radius to 36
                          backgroundColor: swatch[900]!,
                          // backgroundImage: AssetImage(
                          //     "assets/placeholders/default.png"), // Set avatar to placeholder images
                        )),
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
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/backgrounds/graffiti.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.srcOver)),
            ),
          ),
          loading
              ? _messagesSkeleton()
              : Chat(
                  inputOptions: InputOptions(
                      inputClearMode: InputClearMode.never,
                      textEditingController: controller),
                  nameBuilder: (types.User user) {
                    return user.firstName != null
                        ? Text(user.firstName!)
                        : const Text("placeholdser");
                  },
                  l10n: locale, // Set locale
                  // Create basic chat widget
                  messages:
                      _messages, // Set messages to message variable defined above
                  onSendPressed: _handleSendPressed,
                  onMessageTap: (context, p1) {
                    commonLogger.d("eeeeeadss  ${p1.author.id}");
                  },
                  user: getUser(widget.currentUser, "s"), // Set user to user id
                  theme: DefaultChatTheme(
                      primaryColor: swatch[301]!,
                      sentMessageBodyTextStyle: TextStyle(
                          color: swatch[800]!,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5),
                      backgroundColor: Colors.transparent, //swatch[501]!,
                      secondaryColor: swatch[50]!,
                      inputBackgroundColor: swatch[51]!,
                      inputTextColor: swatch[800]!,
                      dateDividerTextStyle: TextStyle(
                          color: swatch[701],
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          height: 1.333),
                      inputMargin: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 8), // Add margins to text input
                      inputBorderRadius: const BorderRadius.all(
                          Radius.circular(24))), // Make input rounded corners
                  onEndReached: () => _loadMoreMessages(),
                ),
        ]));
  }

  void _addMessage(types.Message message) {
    // Define addMessage function
    mounted
        ? setState(() {
            _messages.insert(0, message);
          })
        : null;
  }

  void _handleSendPressed(types.PartialText message) async {
    try {
      if (!sending) {
        controller.clear();
        commonLogger.d("Setting sending to true");
        sending = true;
        // Define handleSendPressed function
        final textMessage = types.TextMessage(
          // Create new message
          author: getUser(widget.currentUser, "s"), // Set author of message
          createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
          id: const Uuid().v1(), // Generate random debug user id
          text: message.text, // Set message content
        );
        _addMessage(textMessage); // Run addMessage function
        await postMessage(widget.channel, message.text, null)
            .then((value) => {sending = false});
      }
    } catch (e) {
      final errorMessage = types.SystemMessage(
        // Create new message
        createdAt: DateTime.now().millisecondsSinceEpoch, // Get time
        id: const Uuid().v1(), // Generate random debug user id
        text: "Message Failed To Send", // Set message content
      );
      _addMessage(errorMessage);
      commonLogger.e("An error Occurred $e");
      sending = false;
    }
  }

  @override
  void dispose() {
    try {
      subscription.cancel(); // Stop listening to new messages
    } catch (e) {
      commonLogger.e("An error has occured: $e");
    }
    super.dispose();
  }
}
