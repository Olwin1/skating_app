import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/followers_list.dart';
import 'package:patinka/profile/following_list.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../api/config.dart';
import '../swatch.dart';

// Lists widget
class Lists extends StatefulWidget {
  const Lists({Key? key, required this.index, this.user}) : super(key: key);

  final int index;
  final Map<String, dynamic>? user;

  @override
  State<Lists> createState() => _Lists();
}

class _Lists extends State<Lists> {
  // Define selectedItemPosition as a late object so it will only be initialised when used.
  late int _selectedItemPosition = widget.index;

  @override
  Widget build(BuildContext context) {
    commonLogger.t("Selected item position: $_selectedItemPosition");
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 8,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          // Setting the bottom of the AppBar
          flexibleSpace: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: SnakeNavigationBar.color(
              backgroundColor: Colors.transparent,
              // Setting the color of the SnakeView
              snakeViewColor: swatch[701],
              // Setting the color of the selected item
              selectedItemColor: swatch[601],
              // Setting the color of the unselected item
              unselectedItemColor: swatch[301],
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
                mounted ? setState(() => _selectedItemPosition = index) : null
              },
              // Setting the items of the SnakeBar
              items: [
                BottomNavigationBarItem(
                    icon: Text(
                  AppLocalizations.of(context)!.followers,
                  style: TextStyle(color: swatch[701]),
                )),
                BottomNavigationBarItem(
                    icon: Text(AppLocalizations.of(context)!.following,
                        style: TextStyle(color: swatch[701]))),
              ],
            ),
          )),
      // Setting the body of the scaffold to a ListView with some UserListWidgets
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: const AssetImage("assets/backgrounds/graffiti.png"),
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.srcOver)),
        ),
        child: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 800), // Duration for animation
            transitionBuilder: (child, animation) {
              // Function to build the transition
              // Define the offset animation using a Tween and the provided animation
              final offsetAnimation = Tween(
                begin:
                    const Offset(1.5, 0.0), // Starting position for the child
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
                ? FollowersList(
                    user: widget
                        .user) // If _selectedItemPosition is 1, show the FollowersList
                : FollowingList(
                    user: widget.user,
                  ) // Otherwise, show the FollowingList
            ),
      ),
    );
  }
}
