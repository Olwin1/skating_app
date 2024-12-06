import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/api/friend_tracker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomSearchBar extends StatefulWidget {
  final MapController mapController;
  final Function focusChangeCallback;

  const CustomSearchBar(
      {super.key,
      required this.mapController,
      required this.focusChangeCallback});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBar();
}

class _CustomSearchBar extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final Map<String, bool> _isInsideFlag = {
    'town:': false,
    'name:': false,
    'postcode:': false,
    'country': false,
  };
  final Map<String, int> _flagStart = {
    'town:': -1,
    'name:': -1,
    'postcode:': -1,
    'country': -1,
  };
  final Map<String, int> _flagEnd = {
    'town:': -1,
    'name:': -1,
    'postcode:': -1,
    'country': -1,
  };
  RegExp exp = RegExp(
      r'(town:|name:|postcode:|country:)"[^"]*"|(town:|name:|postcode:|country:)[^\s]*');

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    String text = _controller.text;
    int cursorPos = _controller.selection.baseOffset;

    for (String flag in _isInsideFlag.keys) {
      if (text.contains(flag)) {
        int flagPos = text.indexOf(flag);
        if (cursorPos > flagPos) {
          _flagStart[flag] = flagPos;
          _flagEnd[flag] = _findFlagEnd(text, flagPos);
          setState(() {
            _isInsideFlag[flag] =
                cursorPos > _flagStart[flag]! && cursorPos <= _flagEnd[flag]!;
          });
        } else {
          setState(() {
            _isInsideFlag[flag] = false;
          });
        }
      } else {
        setState(() {
          _isInsideFlag[flag] = false;
        });
      }
    }
  }

  int _findFlagEnd(String text, int start) {
    int spacePos = text.indexOf(' ', start);
    int quoteStartPos = text.indexOf('"', start);
    int quoteEndPos = -1;

    if (quoteStartPos != -1 && quoteStartPos == start + 5) {
      quoteEndPos = text.indexOf('"', quoteStartPos + 1);
      if (quoteEndPos == -1) {
        return text.length; // Incomplete quoted string
      }
      return quoteEndPos + 1; // Include the closing quotation mark
    }

    if (spacePos == -1) {
      return text.length;
    }

    return spacePos;
  }

  void _onFocusChanged() {
    widget.focusChangeCallback();
    setState(() {
      for (String flag in _isInsideFlag.keys) {
        _isInsideFlag[flag] = _focusNode.hasFocus && _isInsideFlag[flag]!;
      }
    });
  }

  void handlePasteIn(String pasteIn) {
    if (_controller.text.contains(pasteIn)) {
      int index = _controller.text.indexOf("pasteIn");
      _controller.selection =
          TextSelection.collapsed(offset: index + pasteIn.length);
    } else {
      _controller.text += " $pasteIn";
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length - 1);
    }
  }

  Widget suggestionBuilder(String name, String pasteIn) {
    return SizedBox(
        width: double.maxFinite,
        child: TextButton(
            style: const ButtonStyle(alignment: Alignment.centerLeft),
            onPressed: () {
              handlePasteIn(pasteIn);
            },
            child:
                Padding(padding: const EdgeInsets.all(8), child: Text(name))));
  }

  Widget suggestionsBuilder() {
    bool hasTown = _controller.text.contains("town:");
    bool hasName = _controller.text.contains("name:");
    bool hasCountry = _controller.text.contains("country:");
    bool hasPostcode = _controller.text.contains("postcode:");
    List<Widget> suggestions = [];
    if (!hasTown) {
      suggestions.add(suggestionBuilder('town:', 'town:""'));
    }
    if (!hasName) {
      suggestions.add(suggestionBuilder('name:', 'name:""'));
    }
    if (!hasCountry) {
      suggestions.add(suggestionBuilder('country:', 'country:""'));
    }
    if (!hasPostcode) {
      suggestions.add(suggestionBuilder('postcode:', 'postcode:""'));
    }
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16), top: Radius.zero),
                color: Color(0xcf000000)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: suggestions)));
  }

  Future<void> handleSubmit(String value) async {
    Iterable<RegExpMatch> matches = exp.allMatches(value);
    Map<String, String> searchTerms = {};

    for (RegExpMatch match in matches) {
      String matchedText = value.substring(match.start, match.end);
      String flag = _isInsideFlag.keys
          .firstWhere((element) => matchedText.startsWith(element));
      searchTerms[flag] = matchedText;
    }
    Map<String, dynamic> resp = await MessagesAPI.search(searchTerms);
    commonLogger.i(resp);
    widget.mapController.move(LatLng(resp["lat"], resp["lng"]), 17.0);
  }

  @override
  Widget build(BuildContext context) {
    String text = _controller.text;
    List<TextSpan> spans = [];
    int start = 0;

    Iterable<RegExpMatch> matches = exp.allMatches(text);

    for (RegExpMatch match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
            text: text.substring(start, match.start),
            style: const TextStyle(color: Color.fromARGB(255, 226, 202, 202))));
      }
      String matchedText = text.substring(match.start, match.end);
      String flag = _isInsideFlag.keys
          .firstWhere((element) => matchedText.startsWith(element));
      spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
              color: const Color.fromARGB(255, 191, 191, 191),
              backgroundColor: _isInsideFlag[flag]!
                  ? const Color.fromARGB(255, 65, 72, 59)
                  : const Color.fromARGB(255, 44, 49, 40))));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(
          text: text.substring(start, text.length),
          style: const TextStyle(color: Colors.black)));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 0, left: 16.0, right: 16.0),
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification) {
                  // Scroll TextField based on notification details
                  _scrollController.jumpTo(scrollNotification.metrics.pixels);
                }
                return true;
              },
              child: SearchBar(
                hintText: AppLocalizations.of(context)!.search,
                hintStyle: WidgetStateProperty.resolveWith((states) {
                  return const TextStyle(
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 131, 154, 128),
                      height: 1.2,
                      fontFamily: 'Courier',
                      letterSpacing: 1);
                }),
                onSubmitted: (value) async => {await handleSubmit(value)},
                leading: const SizedBox(
                  width: 8,
                ),
                controller: _controller,
                focusNode: _focusNode,
                textStyle: WidgetStateProperty.resolveWith((states) {
                  return const TextStyle(
                      fontSize: 18.0,
                      color: Colors.transparent,
                      height: 1.2,
                      fontFamily: 'Courier',
                      letterSpacing: 1);
                }),
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                shape: WidgetStateProperty.resolveWith((states) {
                  // // If the button is pressed, return size 40, otherwise 20
                  if (states.contains(WidgetState.focused)) {
                    return const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16), bottom: Radius.zero));
                  }
                  return RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0));
                }),
                padding: WidgetStateProperty.resolveWith((states) {
                  return const EdgeInsets.only(
                      top: 8, bottom: 8, left: 0, right: 8);
                }),
                key: const Key("Vis"),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 17, bottom: 8, left: 8, right: 12),
              child: IgnorePointer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 8),
                  key: const Key("Invis"),
                  scrollDirection: Axis.horizontal,
                  controller:
                      _scrollController, // Use the same ScrollController
                  child: RichText(
                    softWrap: false,
                    text: TextSpan(
                        children: spans,
                        style: const TextStyle(
                            fontSize: 18.0,
                            height: 1.2,
                            fontFamily: 'Courier',
                            letterSpacing: 1)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      AnimatedSwitcher(
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0.0, -0.1),
                      end: const Offset(0.0, 0.0))
                  .animate(animation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          duration: const Duration(milliseconds: 200),
          child: _focusNode.hasFocus
              ? suggestionsBuilder()
              : const SizedBox.shrink())
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }
}
