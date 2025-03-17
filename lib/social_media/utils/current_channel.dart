// Singleton class for current channel
class CurrentMessageChannel {
  factory CurrentMessageChannel() => _instance;
  // Private constructor
  CurrentMessageChannel._privateConstructor();
  static final CurrentMessageChannel _instance =
      CurrentMessageChannel._privateConstructor();
  static CurrentMessageChannel get instance => _instance;

  final List<String> stack = [];
  set pushToStack(final String channelId) {
    stack.add(channelId);
  }
  String? get getTopStack {
    try{ 
      return stack.last;
    } on StateError {
      return null;
    }
    }
  void popStack() {
    stack.removeLast();
  }
  // Channel list page will always be "list"


}
