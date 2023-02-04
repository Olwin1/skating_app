import 'package:flutter/material.dart';

const List<String> sessionType = <String>['One', 'Two', 'Three', 'Four'];
const List<String> sessionOptions = <String>['A', 'B', 'C', 'D'];

class SaveSession extends StatefulWidget {
  // Create SaveSession Class
  const SaveSession({Key? key}) : super(key: key);
  @override
  State<SaveSession> createState() => _SaveSession(); //Create state for widget
}

class _SaveSession extends State<SaveSession> {
  String _content = "";
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    myController.addListener(_handleChange);
  }

  void _handleChange() {
    setState(() {
      _content = myController.text;
    });
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // Create appBar
          leadingWidth: 48, // Remove extra leading space
          centerTitle: false, // Align title to left
          title: Title(
            title: "Save Session", //Set title to Save Session
            color: const Color(0xFFDDDDDD),
            child: const Text("Save Session"),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              // Split layout into individual rows
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center Children
                  // Top 2 elements
                  children: [
                    Container(
                      color: const Color(0xffcecece),
                      // Distance Traveled Box
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: const [
                          Text("Distance Traveled"), // Title
                          Text("13km") // Value
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      color: const Color(0xffcecece),
                      // Session Duration Box
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: const [
                          Text("Session Duration"), // Title
                          Text("1:03") // Value
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  color: const Color(0xffcecece),
                  child: Column(
                    children: [
                      const Text("Session Name"),
                      TextField(
                        controller: myController,
                        onChanged: (String value) {
                          setState(() {
                            _content = value;
                          });
                        },
                        autofocus: true,
                      ),
                    ],
                  ),
                ), // Session Name Infobox
                Container(
                  color: const Color(0xffcecece),
                  child: Column(
                    children: [
                      const Text("Session Description"),
                      TextField(
                        maxLines: 4,
                        minLines: 4,
                        maxLength: 250,

                        //controller: myController,
                        onChanged: (String value) {
                          setState(() {
                            _content = value;
                          });
                        },
                        autofocus: true,
                      ),
                    ],
                  ),
                ), // Session Description Infobox
                TextButton(
                    onPressed: () => print("Add photos"),
                    child: const Text("Add Photos")), // Add Photos Infobox
                Container(
                    color: const Color(0xffcecece),
                    child: Column(
                      children: const [
                        Text("Session Type"),
                        ShareOptions(
                          id: 1,
                        )
                      ],
                    )), // Session Type Infobox
                Container(
                    color: const Color(0xffcecece),
                    child: Column(
                      children: const [
                        Text("Share Options"),
                        ShareOptions(
                          id: 0,
                        )
                      ],
                    )), // Share to Infobox
                TextButton(
                  onPressed: () => print("Session Saved"),
                  child: const Text("Save Session"),
                ) // Save Session Infobox
              ],
            )));
  }
}

// ! move to 2 seperate classes for performance
class ShareOptions extends StatefulWidget {
  // Constructor for the ShareOptions widget
  // Takes in a required `id` property to distinguish between two ShareOptions widgets
  const ShareOptions({super.key, required this.id});

  // `id` property to distinguish between two `ShareOptions` widgets
  final int id;

  // Returns the state object associated with this widget
  @override
  State<ShareOptions> createState() => _ShareOptionsState();
}

class _ShareOptionsState extends State<ShareOptions> {
  // `dropdownValueA` holds the selected value for the first dropdown
  String dropdownValueA = sessionType.first;

  // `dropdownValueB` holds the selected value for the second dropdown
  String dropdownValueB = sessionOptions.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      // Set the value of the dropdown to `dropdownValueA` if `widget.id` is 1,
      // otherwise set it to `dropdownValueB`
      value: widget.id == 1 ? dropdownValueA : dropdownValueB,

      // Icon to display at the right of the dropdown button
      icon: const Icon(Icons.arrow_downward),

      // Elevation of the dropdown when it's open
      elevation: 16,

      // Style for the text inside the dropdown button
      style: const TextStyle(color: Colors.deepPurple),

      // Style for the line under the dropdown button
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),

      // Callback function called when an item is selected
      onChanged: (String? value) {
        setState(() {
          // Update the selected value in the corresponding `dropdownValue`
          // depending on the value of `widget.id`
          widget.id == 1 ? dropdownValueA = value! : dropdownValueB = value!;
        });
      },

      // Items to show in the dropdown
      items: widget.id == 1
          ? sessionType.map<DropdownMenuItem<String>>((String value) {
              // Create a dropdown item for each value in `sessionType`
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList()
          // Create a dropdown item for each value in `sessionOptions`
          : sessionOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
    );
  }
}
