import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/profile/user_list_widget.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

// Defining some constants for the SnakeNavigationBar
const SnakeShape snakeShape = SnakeShape.circle;
const Color selectedColor = Color(0xff4343cd);
int _selectedItemPosition = 2;

// Lists widget
class Lists extends StatefulWidget {
  const Lists({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Lists> createState() => _Lists();
}

class _Lists extends State<Lists> {
  @override
  Widget build(BuildContext context) {
    // Creating a user object
    User user = User("1");

    return Scaffold(
        appBar: AppBar(
            // Setting the title of the AppBar
            title: const Text("username"),
            // Setting the bottom of the AppBar
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: SnakeNavigationBar.color(
                // Setting the color of the SnakeView
                snakeViewColor: selectedColor,
                // Setting the color of the selected item
                selectedItemColor: const Color(0xff4d3d2d),
                // Setting the color of the unselected item
                unselectedItemColor: Colors.blueGrey,
                // Setting the behaviour of the SnakeBar
                behaviour: SnakeBarBehaviour.pinned,
                // Setting the shape of the Snake
                snakeShape: const SnakeShape(
                  shape: RoundedRectangleBorder(),
                  padding: EdgeInsets.only(right: 10),
                  height: 3,
                ),
                // Setting the padding of the SnakeBar
                padding: EdgeInsets.zero,
                // Setting whether to show unselected labels
                showUnselectedLabels: true,
                // Setting whether to show selected labels
                showSelectedLabels: true,
                // Setting the current index of the SnakeBar
                currentIndex: _selectedItemPosition,
                // Setting the onTap function of the SnakeBar
                onTap: (index) => setState(() => _selectedItemPosition = index),
                // Setting the items of the SnakeBar
                items: const [
                  BottomNavigationBarItem(icon: Text("Followers")),
                  BottomNavigationBarItem(icon: Text("Following")),
                ],
              ),
            )),
        // Setting the body of the scaffold to a ListView with some UserListWidgets
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: const [
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
            UserListWidget(title: "title"),
          ],
        ));
  }
}
