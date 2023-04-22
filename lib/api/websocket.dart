import 'dart:async';

import 'package:skating_app/api/token.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'config.dart';

SecureStorage storage = SecureStorage();

// Creates a class for a WebSocketConnection
class WebSocketConnection {
  // Creates a StreamController to broadcast events
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getter method for the stream controller's stream
  Stream<Map<String, dynamic>> get stream => _streamController.stream;

  // Creates a variable to store the io.Socket instance
  late io.Socket socket;

  // Constructor for the WebSocketConnection class
  WebSocketConnection() {
    _connect(); // calls the _connect() method to establish a connection
  }

  // Method to connect to the WebSocket
  void _connect() async {
    try {
      print("connectiong"); // logs to console
      // Creates an io.Socket instance with the given configuration
      socket = io.io(
          Config.uri,
          io.OptionBuilder()
              .setTransports(['websocket']) // sets the transport method
              .disableAutoConnect() // Don't connect until told to
              .setExtraHeaders(
                  {'token': await storage.getToken()}) // sets extra headers
              .build());
      // Adds a listener for the 'connect' event
      socket.onConnect((_) {
        print('connect'); // logs to console
        socket.emit('msg', 'test'); // emits a test message to the server
      });
      // Adds a listener for the 'newMessage' event
      socket.on('newMessage', (data) {
        print(data); // logs the received data to console
        _streamController.add(data); // adds data to the stream controller
      });
      // Adds a listener for the 'disconnect' event
      socket.onDisconnect((_) => print('disconnect')); // logs to console
    } catch (e) {
      print('Error connecting to WebSocket: $e'); // logs any errors to console
    }
  }
}
