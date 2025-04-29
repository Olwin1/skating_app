// ignore_for_file: cascade_invocations

import "dart:async";

import "package:patinka/api/config.dart";
import "package:patinka/common_logger.dart";
import "package:socket_io_client/socket_io_client.dart" as io;

enum TypingState { started, typing, stopped }

// Creates a class for a WebSocketConnection
class WebSocketConnection {
  // Constructor for the WebSocketConnection class
  WebSocketConnection() {
    _connect(); // calls the _connect() method to establish a connection
  }
  // Creates a StreamController to broadcast events
  final StreamController<Map<String, dynamic>> _streamControllerMessages =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _streamControllerSeen =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _streamControllerTyping =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>>
      _streamControllerMessagesDelivered =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getter method for the stream controller's stream
  Stream<Map<String, dynamic>> get streamMessages =>
      _streamControllerMessages.stream;
  Stream<Map<String, dynamic>> get streamSeen => _streamControllerSeen.stream;
  Stream<Map<String, dynamic>> get streamTyping =>
      _streamControllerTyping.stream;
  Stream<Map<String, dynamic>> get streamMessagesDelivered =>
      _streamControllerMessagesDelivered.stream;

  // Creates a variable to store the io.Socket instance
  late io.Socket socket;

  // Method to connect to the WebSocket
  void _connect() async {
    try {
      commonLogger.t("Connecting to websocket"); // logs to console
      // Creates an io.Socket instance with the given configuration
      socket = io.io(
          Config.uri,
          io.OptionBuilder()
              .setTransports(["websocket"]) // sets the transport method
              .disableAutoConnect() // Don't connect until told to
              .setExtraHeaders(
                  {"token": await storage.getToken()}) // sets extra headers
              .build());
      // Adds a listener for the 'connect' event
      socket.onConnect((final _) {
        commonLogger.d("Sending test message"); // logs to console
        socket.emit("msg", "test"); // emits a test message to the server
      });
      // Adds a listener for the 'newMessage' event
      socket.on("newMessage", (final data) {
        commonLogger.d(
            "Sending NewMessage: $data"); // logs the received data to console
        _streamControllerMessages
            .add(data); // adds data to the stream controller
      });

      // Adds a listener for the 'newSeen' event
      socket.on("newSeen", (final data) {
        commonLogger
            .d("Sending NewSeen: $data"); // logs the received data to console
        _streamControllerSeen.add(data); // adds data to the stream controller
      });

      // Adds a listener for the 'newTyping' event
      socket.on("newTyping", (final data) {
        TypingState typingState;
        switch (data["typingState"]) {
          case 2:
            typingState = TypingState.started;
          case 1:
            typingState = TypingState.typing;
          default:
            typingState = TypingState.stopped;
        }
        final Map<String, dynamic> e = data;
        e["typingState"] = typingState;
        commonLogger
            .d("Sending NewTyping: $e"); // logs the received data to console
        _streamControllerTyping.add(e); // adds data to the stream controller
      });

      // Adds a listener for the 'delivered' event
      socket.on("delivered", (final data) {
        commonLogger
            .d("Sending Delivered: $data"); // logs the received data to console
        _streamControllerMessagesDelivered
            .add(data); // adds data to the stream controller
      });

      // Adds a listener for the 'disconnect' event
      socket.onDisconnect((final _) =>
          commonLogger.t("Disconnecting from socket")); // logs to console
    } catch (e) {
      commonLogger
          .e("Error connecting to WebSocket: $e"); // logs any errors to console
    }
  }

  // Method to emit a message to the server
  Future<bool> emitMessage(
      final String channel, final String content, final String? image) async {
    if (socket.connected) {
      socket.emit("message", {"channel": channel, "content": content});
      commonLogger.d("Emitting message, Data: $content");
      return true;
    } else {
      commonLogger.e("Socket is not connected. Cannot emit message.");
      return false;
    }
  }

  // Method to emit a message to the server
  Future<bool> emitSeenMessage(final String channel, final int messageNumber,
      final String messageId) async {
    if (socket.connected) {
      socket.emit("seen", {
        "channel": channel,
        "messageNumber": messageNumber,
        "messageId": messageId
      });
      commonLogger.d("Emitting seen, Message Number: $messageNumber");
      return true;
    } else {
      commonLogger.e("Socket is not connected. Cannot emit message.");
      return false;
    }
  }

  Future<bool> emitTyping(
      final String channel, final TypingState typingState) async {
    if (socket.connected) {
      int typingStateRaw;
      switch (typingState) {
        case TypingState.started:
          typingStateRaw = 2;
        case TypingState.typing:
          typingStateRaw = 1;
        case TypingState.stopped:
          typingStateRaw = 0;
      }

      socket
          .emit("typing", {"channel": channel, "typingState": typingStateRaw});
      commonLogger.d("Emitting typing, Typing State: $typingState");
      return true;
    } else {
      commonLogger.e("Socket is not connected. Cannot emit message.");
      return false;
    }
  }
}
