import 'package:flutter/material.dart';
import 'package:skating_app/profile/followers_list.dart';
import 'package:skating_app/profile/following_list.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Defining some constants for the SnakeNavigationBar
const SnakeShape snakeShape = SnakeShape.circle;
const Color selectedColor = Color(0xff4343cd);

// Lists widget
class Lists extends StatefulWidget {
  const Lists({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  State<Lists> createState() => _Lists();
}

class _Lists extends State<Lists> {
  // Define selectedItemPosition as a late object so it will only be initialised when used.
  late int _selectedItemPosition = widget.index;

  @override
  Widget build(BuildContext context) {
    print(_selectedItemPosition);
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
              onTap: (index) => {
                setState(() => {_selectedItemPosition = index})
              },
              // Setting the items of the SnakeBar
              items: [
                BottomNavigationBarItem(
                    icon: Text(AppLocalizations.of(context)!.followers)),
                BottomNavigationBarItem(
                    icon: Text(AppLocalizations.of(context)!.following)),
              ],
            ),
          )),
      // Setting the body of the scaffold to a ListView with some UserListWidgets
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800), // Duration for animation
          transitionBuilder: (child, animation) {
            // Function to build the transition
            // Define the offset animation using a Tween and the provided animation
            final offsetAnimation = Tween(
              begin: const Offset(1.5, 0.0), // Starting position for the child
              end: const Offset(0.0, 0.0), // Ending position for the child
            ).animate(animation);
            // Return the child wrapped in a ClipRect and SlideTransition
            return ClipRect(
              // Use the offset animation to position the child
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          child: _selectedItemPosition == 0 // The child widget to animate
              ? const FollowersList() // If _selectedItemPosition is 1, show the FollowersList
              : const FollowingList() // Otherwise, show the FollowingList
          ),
    );
  }
}
