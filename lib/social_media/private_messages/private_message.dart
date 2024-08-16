// Import necessary Dart and Flutter packages
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:patinka/social_media/private_messages/session_notification.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/misc/navbar_provider.dart';
import 'package:patinka/api/websocket.dart';
import 'package:patinka/common_logger.dart';
import 'package:uuid/uuid.dart';
import '../../api/config.dart';
import '../../api/messages.dart';
import '../../api/social.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../misc/default_profile.dart';
import '../../swatch.dart';

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

// Define a StatefulWidget for displaying private messages
class PrivateMessage extends StatefulWidget {
  // Constructor takes an index and a channel as arguments
  const PrivateMessage({
    super.key,
    required this.index,
    this.channel,
    this.user,
    required this.currentUser,
    this.callback,
  });

  final int index;
  final Map<String, dynamic>? channel;
  final Map<String, dynamic>? user;
  final String currentUser;
  final Function? callback;

  @override
  State<PrivateMessage> createState() => _PrivateMessage();
}

// Define the state for PrivateMessage widget
class _PrivateMessage extends State<PrivateMessage> {
  bool sending = false;
  String? channelId;
  final List<types.Message> _messages = [];
  int _page = 0;
  bool loading = false;
  bool userFound = false;
  late StreamSubscription subscription;
  TextEditingController controller = TextEditingController();
  types.User? user;

  @override
  void initState() {
    // Initialize the user if not already initialized
    if (user == null) {
      getUser(null).then(
        (value) => {
          user = value,
          setState(() => userFound = true),
        },
      );
    } else {
      setState(() => userFound = true);
    }

    channelId = widget.channel?["channel_id"];
    super.initState();

    // Load initial messages
    loadMessages();

    // Join the channel using websockets
    getIt<WebSocketConnection>().socket.emit("joinChannel", [channelId]);

    // Subscribe to the websocket stream
    subscription = getIt<WebSocketConnection>().stream.listen(
          (data) => updateMessages(data),
        );
  }

  // Function to show a skeleton UI while messages are loading
  Widget _messagesSkeleton() {
    Widget child(bool lalign, double width) {
      return Shimmer.fromColors(
        baseColor: shimmer["base"]!,
        highlightColor: shimmer["highlight"]!,
        child: Container(
          width: 100,
          padding: const EdgeInsets.only(top: 8),
          child: Align(
            alignment: lalign ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xb5000000),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              height: 42,
              width: width,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      );
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
      ),
    );
  }

  // List to store user information
  List<types.User> users = [];

  // Function to get user information
  Future<types.User> getUser(String? id) async {
    String userId = id ?? widget.currentUser;

    // Check if user information is already fetched
    for (var i = 0; i < users.length; i++) {
      if (users[i].id == userId) {
        commonLogger.d(users[i]);
        return users[i];
      }
    }

    // Fetch user information from the API
    Map<String, dynamic> user = await SocialAPI.getUser(userId);
    types.User newUser = types.User(
      id: userId,
      firstName: user["username"],
      imageUrl: user["avatar_id"] == null
          ? null
          : "${Config.uri}/image/${user["avatar_id"]}",
    );

    // Cache the user information
    users.add(newUser);
    return newUser;
  }

  // Function to update messages when new messages arrive
  void updateMessages(Map<String, dynamic> data) async {
    if (data["channel"] == channelId) {
      commonLogger.d("ITS A MATCH!");
      User user = await getUser(data["sender"]);
      // Add the new message to the beginning of the list
      mounted
          ? setState(() {
              _messages.insert(
                0,
                types.TextMessage(
                  author: user,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  id: const Uuid().v1(),
                  text: data["content"],
                ),
              );
            })
          : null;
    } else {
      showNotification(context, data, widget.currentUser);
    }
  }

  // Function to load initial messages
  Future<void> loadMessages() async {
    if (loading) {
      return;
    }

    loading = true;
    List<types.Message> messages = [];

    if (channelId != null) {
      final messagesRaw = await MessagesAPI.getMessages(_page, channelId!);
      for (int i = 0; i < messagesRaw.length; i++) {
        dynamic message = messagesRaw[i];
        messages.add(
          types.TextMessage(
            author: await getUser(message["sender_id"]),
            createdAt:
                DateTime.parse(message["date_sent"]).millisecondsSinceEpoch,
            id: message["message_id"],
            text: message["content"],
          ),
        );
      }
    }

    mounted
        ? setState(() {
            _messages.addAll(messages);
            _page++;
            loading = false;
          })
        : null;
  }

  // Function to load more messages when reaching the end
  Future<void> _loadMoreMessages() async {
    if (channelId != null) {
      commonLogger.t("Loading more messages");
      final nextPage = _page + 1;
      final messagesRaw = await MessagesAPI.getMessages(nextPage, channelId!);
      List<types.Message> messages = [];
      for (int i = 0; i < messagesRaw.length; i++) {
        dynamic message = messagesRaw[i];
        messages.add(
          types.TextMessage(
            author: await getUser(message["sender_id"]),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: message["message_id"],
            text: message["content"],
          ),
        );
      }

      mounted
          ? setState(() {
              _messages.addAll(messages);
              _page = nextPage;
            })
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide the Navbar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Set locale based on the language
    ChatL10n locale;
    switch (AppLocalizations.of(context)!.localeName) {
      case "pl":
        locale = const ChatL10nPl();
        break;
      default:
        locale = const ChatL10nEn();
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (bool hasPopped) => _onWillPop(hasPopped),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          // App Bar Configuration
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 8,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          leadingWidth: 48,
          centerTitle: false,
          title: Row(
            children: [
              // Display user information in the app bar
              widget.user == null
                  ? Shimmer.fromColors(
                      baseColor: shimmer["base"]!,
                      highlightColor: shimmer["highlight"]!,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: swatch[900],
                      ),
                    )
                  : (widget.user!["avatar_id"] != null &&
                          widget.user!["avatar_id"] != "default")
                      ? CachedNetworkImage(
                          height: 40,
                          width: 40,
                          imageUrl:
                              '${Config.uri}/image/thumbnail/${widget.user!["avatar_id"]}',
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: swatch[900],
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        )
                      : const DefaultProfile(radius: 20),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display username
                    Text(
                      widget.user?["username"] ??
                          AppLocalizations.of(context)!.username,
                      style: TextStyle(fontSize: 16, color: swatch[701]),
                    ),
                    // Display last activity status
                    Text(
                      AppLocalizations.of(context)!.activityOnline,
                      style: TextStyle(fontSize: 12, color: swatch[601]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Show skeleton UI while loading or user information not found
            loading || !userFound
                ? _messagesSkeleton()
                : Chat(
                    inputOptions: InputOptions(
                      inputClearMode: InputClearMode.never,
                      textEditingController: controller,
                    ),
                    nameBuilder: (types.User user) {
                      return user.firstName != null
                          ? Text(user.firstName!)
                          : const Text("placeholdser");
                    },
                    l10n: locale,
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    onMessageTap: (context, p1) {
                      commonLogger.d("eeeeeadss  ${p1.author.id}");
                    },
                    user: user!,
                    theme: DefaultChatTheme(
                      primaryColor: swatch[301]!,
                      sentMessageBodyTextStyle: TextStyle(
                        color: swatch[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      backgroundColor: Colors.transparent,
                      secondaryColor: swatch[50]!,
                      inputBackgroundColor: swatch[51]!,
                      inputTextColor: swatch[800]!,
                      dateDividerTextStyle: TextStyle(
                        color: swatch[701],
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.333,
                      ),
                      inputMargin: const EdgeInsets.only(
                        left: 0,
                        right: 0,
                        bottom: 0,
                      ),
                      inputPadding: const EdgeInsets.all(16),
                      inputBorderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    onEndReached: () => _loadMoreMessages(),
                  ),
          ],
        ),
      ),
    );
  }

  // Function to add a new message to the message list
  void _addMessage(types.Message message) {
    mounted
        ? setState(() {
            _messages.insert(0, message);
          })
        : null;
  }

  // Function to handle send button press
  void _handleSendPressed(types.PartialText message) async {
    try {
      if (!sending) {
        controller.clear();
        commonLogger.d("Setting sending to true");
        sending = true;

        // Create a new text message
        final textMessage = types.TextMessage(
          author: await getUser(widget.currentUser),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v1(),
          text: message.text,
        );

        // Add the message to the message list
        _addMessage(textMessage);

        // Send the message to the server
        if (channelId != null) {
          await getIt<WebSocketConnection>()
              .emitMessage(channelId!, message.text, null)
              .then((value) => {sending = false});
        } else {
          // If there is no channel ID, create a new channel
          List<String> participants = [widget.currentUser];
          Map<String, dynamic> channel =
              await MessagesAPI.postChannel(participants);
          channelId = channel["channel"]["channel_id"];
          if (channelId != null) {
            await MessagesAPI.postMessage(channelId!, message.text, null)
                .then((value) => {sending = false});
          }
          if (widget.callback != null) {
            widget.callback!();
          }
          commonLogger.d(channel);
        }
      }
    } catch (e) {
      // Handle errors when sending messages
      final errorMessage = types.SystemMessage(
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v1(),
        text: "Message Failed To Send",
      );
      _addMessage(errorMessage);
      commonLogger.e("An error Occurred $e");
      sending = false;
    }
  }

  // Function to handle back navigation
  Future<bool> _onWillPop(bool hasPopped) async {
    if (mounted && widget.channel == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .popUntil(ModalRoute.withName('/PrivateMessageList'));
      });
    }
    return true;
  }

  // Clean up resources when the widget is disposed
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
