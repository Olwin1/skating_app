import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skating_app/objects/user.dart';

// UserListWidget class creates a stateful widget that displays a list of users
class UserListWidget extends StatefulWidget {
  // Constructor for UserListWidget
  const UserListWidget({Key? key, required this.id}) : super(key: key);

  // Title for the widget
  final String id;

  // Creates the state for the UserListWidget
  @override
  State<UserListWidget> createState() => _UserListWidget();
}

// _UserListWidget class is the state of the UserListWidget
class _UserListWidget extends State<UserListWidget> {
  Map<String, dynamic>? user;

  // Builds the widget
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      getUserCache(widget.id).then((value) => setState(() {
            user = value;
          }));
    }
    // Returns a row with a CircleAvatar, a text widget, and a TextButton
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // CircleAvatar with a radius of 26 and a background image from the assets folder
            const Padding(
              padding: EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage("assets/placeholders/150.png"),
              ),
            ),
            // Text widget with the text "username"
            Text(user?["username"] ?? AppLocalizations.of(context)!.username),
            // TextButton with an onPressed function that prints test value "ee" and a child text widget with the text "Follow"
            TextButton(
                onPressed: () => print("ee"),
                child: Text(AppLocalizations.of(context)!.follow))
          ],
        ));
  }
}
