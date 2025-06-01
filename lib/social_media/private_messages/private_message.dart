// Import necessary Dart and Flutter packages
import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_chat_types/flutter_chat_types.dart" as types;
import "package:flutter_chat_types/flutter_chat_types.dart";
import "package:flutter_chat_ui/flutter_chat_ui.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:get_it/get_it.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/api/social.dart";
import "package:patinka/api/websocket.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/modals/message_options_modal.dart";
import "package:patinka/misc/notifications/session_notification.dart";
import "package:patinka/social_media/user_reports/report_user.dart";
import "package:patinka/social_media/utils/current_channel.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:shimmer/shimmer.dart";
import "package:uuid/uuid.dart";

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

// Define a StatefulWidget for displaying private messages
class PrivateMessage extends StatefulWidget {
  // Constructor takes an index and a channel as arguments
  const PrivateMessage(
      {required this.initSelf,
      required this.currentUser,
      this.updateChannelMessage,
      super.key,
      this.channel,
      this.user,
      this.callback});

  final bool initSelf;
  final Map<String, dynamic>? channel;
  final Map<String, dynamic>? user;
  final String currentUser;
  final Function? callback;
  final Function? updateChannelMessage;

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
  late StreamSubscription subscriptionMessages;
  late StreamSubscription subscriptionSeen;
  late StreamSubscription subscriptionTyping;
  late StreamSubscription subscriptionMessagesDelivered;
  TextEditingController controller = TextEditingController();
  types.User? user;

  Timer? _typingTimer;
  //Has a callback function - is used
  // ignore: unused_field
  Timer? _keepaliveTimer;
  final Duration typingDelay =
      const Duration(seconds: 3); // 3 to 5 seconds delay
  final Duration keepaliveDelay =
      const Duration(seconds: 3); // 3 to 5 seconds delay
  bool isTyping = false;

  @override
  void initState() {
    controller.addListener(_onTextChanged);
    // Initialize the user if not already initialized
    if (user == null) {
      getUser(null).then(
        (final value) => {
          user = value,
          setState(() => userFound = true),
        },
      );
    } else {
      setState(() => userFound = true);
    }
    //getUser("387949971204341760").then((value) => setState(() {typingUsers.add(value); typingUsers.add(value); typingUsers.add(value);})); //Temp for typing

    channelId = widget.channel?["channel_id"];
    super.initState();

    // Add to stack tracking current pages
    CurrentMessageChannel.instance.pushToStack = widget.channel?["channel_id"];

    // Load initial messages
    loadMessages();

    // Join the channel using websockets
    getIt<WebSocketConnection>().socket.emit("joinChannel", [channelId]);

    // Subscribe to the websocket stream
    subscriptionMessages = getIt<WebSocketConnection>().streamMessages.listen(
          updateMessages,
        );
    subscriptionSeen = getIt<WebSocketConnection>().streamSeen.listen(
          updateSeen,
        );
    subscriptionTyping = getIt<WebSocketConnection>().streamTyping.listen(
          handleTyping,
        );
    subscriptionMessagesDelivered =
        getIt<WebSocketConnection>().streamMessagesDelivered.listen(
              updateDelivered,
            );
  }

  void _onTextChanged() {
    if (!isTyping) {
      _onTypingStarted();
    }

    _resetTypingTimer();
  }

  void _onTypingStarted() {
    isTyping = true;

    commonLogger.d("User started typing");
    channelId == null
        ? null
        : getIt<WebSocketConnection>()
            .emitTyping(channelId!, TypingState.started);
    _startTypingCheckTimer();
  }

  void _onTypingStopped() {
    isTyping = false;
    commonLogger.d("User stopped typing");
    channelId == null
        ? null
        : getIt<WebSocketConnection>()
            .emitTyping(channelId!, TypingState.stopped);
    _typingTimer?.cancel();
  }

  void _startTypingCheckTimer() {
    _typingTimer?.cancel(); // Cancel any existing timer
    _keepaliveTimer = Timer.periodic(typingDelay, (final timer) {
      if (isTyping) {
        commonLogger.d("User is still typing...");
        channelId == null
            ? null
            : getIt<WebSocketConnection>()
                .emitTyping(channelId!, TypingState.typing);
      } else {
        timer.cancel();
      }
    });
  }

  void _resetTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer(typingDelay, _onTypingStopped);
  }

  // Function to show a skeleton UI while messages are loading
  Widget _messagesSkeleton() {
    Widget child(final bool lalign, final double width) => Shimmer.fromColors(
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
  Future<types.User> getUser(final String? id) async {
    final String userId = id ?? widget.currentUser;

    // Check if user information is already fetched
    for (var i = 0; i < users.length; i++) {
      if (users[i].id == userId) {
        commonLogger.d(users[i]);
        return users[i];
      }
    }

    // Fetch user information from the API
    final Map<String, dynamic> user = await SocialAPI.getUser(userId);
    final types.User newUser = types.User(
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
  void updateMessages(final Map<String, dynamic> data) async {
    if (data["channel"] == channelId) {
      commonLogger.d("ITS A MATCH!");
      final User user = await getUser(data["sender"]);
      // Add the new message to the beginning of the list
      mounted
          ? setState(() {
              _messages.insert(
                0,
                types.TextMessage(
                  showStatus: true,
                  author: user,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  id: data["messageNumber"].toString(),
                  text: data["content"],
                ),
              );
            })
          : null;

      //TODO Convert to a widget and function when next available

      // Update last message sent on channel menu
      if (widget.updateChannelMessage != null) {
        // ignore: prefer_null_aware_method_calls
        widget.updateChannelMessage!(data["content"]);
      }
      // -------------------

      getIt<WebSocketConnection>().emitSeenMessage(
          data["channel"], data["messageNumber"], data["messageId"]);
    } else {
      showNotification(context, data, widget.currentUser);
    }
  }

  // Function to update messages when new messages arrive
  void updateSeen(final Map<String, dynamic> data) async {
    if (data["channel"] == channelId) {
      final String messageNumber = data["messageNumber"].toString();
      commonLogger.d("ITS A MATCH for seen!");
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].id == messageNumber) {
          setState(() {
            _messages[i] = _messages[i].copyWith(status: Status.seen);
          });
        }
      }
    }
  }

  void updateDelivered(final Map<String, dynamic> data) async {
    if (data["channel"] == channelId) {
      final String messageNumber = data["messageNumber"].toString();
      commonLogger.d("ITS A MATCH for seen!");
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].author == user &&
            _messages[i].status == Status.sending &&
            _messages[i].metadata!["content"] == data["content"]) {
          setState(() {
            _messages[i] = _messages[i]
                .copyWith(status: Status.delivered, id: messageNumber);
          });
        }
      }
    }
  }

  // Function to load initial messages
  Future<void> loadMessages() async {
    if (loading) {
      return;
    }

    loading = true;
    final List<types.Message> messages = [];

    if (channelId != null) {
      final messagesRaw = await MessagesAPI.getMessages(_page, channelId!);
      for (int i = 0; i < messagesRaw.length; i++) {
        final dynamic message = messagesRaw[i];
        final List<String> messageReaders = [];
        for (int j = 0; j < message["message_readers"].length; j++) {
          messageReaders.add(message["message_readers"][j]["user_id"]);
          if (message["message_readers"][j]["user_id"] == widget.currentUser) {
            break;
          }
        }

        // Create message on screen
        messages.add(
          types.TextMessage(
            status: messageReaders.isNotEmpty ? Status.seen : Status.delivered,
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
      final List<types.Message> messages = [];
      for (int i = 0; i < messagesRaw.length; i++) {
        final dynamic message = messagesRaw[i];
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

  Map<String, Timer> typingUserTimers = {};
  void handleTyping(final Map<String, dynamic> data) {
    if (data["channel"] == channelId) {
      switch (data["typingState"]) {
        case TypingState.started:
        case TypingState.typing:
          if (typingUserTimers.containsKey(data["sender"])) {
            //If is existing typing user
            typingUserTimers[data["sender"]]!.cancel();
          }
          typingUserTimers[data["sender"]] =
              Timer.periodic(typingDelay, (final timer) {
            handleTypingCancel(data);
          });
          bool found = false;
          for (int i = 0; i < typingUsers.length; i++) {
            if (typingUsers[i].id == data["sender"]) {
              found = true;
              break;
            }
          }
          if (!found) {
            getUser(data["sender"]).then((final value) => {
                  setState(() {
                    typingUsers.add(value);
                  })
                });
          }
        default:
          handleTypingCancel(data);
      }
    }
  }

  List<User> typingUsers = [];

  void handleTypingCancel(final Map<String, dynamic> data) {
    if (typingUserTimers.containsKey(data["sender"])) {
      typingUserTimers.remove(data["sender"])!.cancel();
    }
    for (int i = 0; i < typingUsers.length; i++) {
      if (typingUsers[i].id == data["sender"]) {
        setState(() {
          typingUsers.removeAt(i);
        });
        break;
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    // Hide the Navbar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    if (getIt<WebSocketConnection>().socket.disconnected) {
      getIt<WebSocketConnection>().socket.connect();
    }

    // Set locale based on the language
    ChatL10n locale;
    switch (AppLocalizations.of(context)!.localeName) {
      case "pl":
        locale = const ChatL10nPl();
      default:
        locale = const ChatL10nEn();
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (final bool hasPopped, final result) =>
          _onWillPop(hasPopped),
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
                          placeholder: (final context, final url) =>
                              Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: swatch[900],
                            ),
                          ),
                          imageBuilder: (final context, final imageProvider) =>
                              Container(
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
                    typingIndicatorOptions: TypingIndicatorOptions(
                        typingMode: TypingIndicatorMode.both,
                        typingUsers: typingUsers),
                    customStatusBuilder: (final message,
                            {required final BuildContext context}) =>
                        MessageStatus(
                      status: message.status,
                    ),
                    inputOptions: InputOptions(
                      inputClearMode: InputClearMode.never,
                      textEditingController: controller,
                    ),
                    nameBuilder: (final types.User user) =>
                        user.firstName != null
                            ? Text(user.firstName!)
                            : const Text("placeholdser"),
                    l10n: locale,
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    onMessageTap: (final context, final p1) {
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
                        inputMargin: EdgeInsets.zero,
                        inputPadding: const EdgeInsets.all(16),
                        inputBorderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        typingIndicatorTheme: TypingIndicatorTheme(
                            animatedCirclesColor: swatch[801]!,
                            animatedCircleSize: 6,
                            bubbleBorder: BorderRadius.circular(1),
                            bubbleColor: Colors.transparent,
                            countAvatarColor: swatch[700]!,
                            countTextColor: swatch[701]!,
                            multipleUserTextStyle:
                                TextStyle(color: swatch[801]))),
                    onEndReached: _loadMoreMessages,
                    onMessageLongPress: (final context, final message) {
                      ModalBottomSheet.show(
                          context: context,
                          builder: (final context) => MessageOptionsBottomSheet(
                                message: message,
                              ),
                          startSize: 0.2,
                          hideNavbar: false);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // Function to add a new message to the message list
  void _addMessage(final types.Message message) {
    mounted
        ? setState(() {
            _messages.insert(0, message);
          })
        : null;

    //TODO Convert to a widget and function when next available

    // Update last message sent on channel menu
    if (widget.updateChannelMessage != null && message is types.TextMessage) {
      // ignore: prefer_null_aware_method_calls
      widget.updateChannelMessage!(message.text);
    }
    // ----------------------------
  }

  // Function to handle send button press
  void _handleSendPressed(final types.PartialText message) async {
    try {
      if (!sending) {
        controller.clear();
        commonLogger.d("Setting sending to true");
        sending = true;

        // Create a new text message
        final textMessage = types.TextMessage(
          showStatus: true,
          status: Status.sending,
          author: await getUser(widget.currentUser),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v1(),
          text: message.text,
          metadata: {"content": message.text},
        );

        // Add the message to the message list
        _addMessage(textMessage);

        // Send the message to the server
        if (channelId != null) {
          await getIt<WebSocketConnection>()
              .emitMessage(channelId!, message.text, null)
              .then((final value) => {sending = false});
        } else {
          // If there is no channel ID, create a new channel
          final List<String> participants = [widget.currentUser];
          final Map<String, dynamic> channel =
              await MessagesAPI.postChannel(participants);
          channelId = channel["channel"]["channel_id"];
          if (channelId != null) {
            await MessagesAPI.postMessage(channelId!, message.text, null)
                .then((final value) => {sending = false});
          }
          widget.callback!();
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
  Future<bool> _onWillPop(final bool hasPopped) async {
    if (mounted && widget.channel == null) {
      SchedulerBinding.instance.addPostFrameCallback((final _) {
        Navigator.of(context)
            .popUntil(ModalRoute.withName("/PrivateMessageList"));
      });
    }
    return true;
  }

  // Clean up resources when the widget is disposed
  @override
  void dispose() {
    try {
      // Pop from top stack
      CurrentMessageChannel.instance.popStack();

      subscriptionMessages.cancel(); // Stop listening to new messages
      subscriptionSeen.cancel(); // Stop listening to new seen
      subscriptionTyping.cancel(); // Stop listening to new typing
      subscriptionMessagesDelivered.cancel();

      controller.removeListener(_onTextChanged);
      _typingTimer?.cancel();
      _keepaliveTimer?.cancel();
    } catch (e) {
      commonLogger.e("An error has occured: $e");
    }
    super.dispose();
  }
}
