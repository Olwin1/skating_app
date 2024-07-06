import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchBarr extends StatelessWidget {
  const SearchBarr({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Text Input')),
      body: const CustomTextInput(),
    );
  }
}

class CustomTextInput extends StatefulWidget {
  const CustomTextInput({super.key});

  @override
  State<CustomTextInput> createState() => _CustomTextInput();
}

class _CustomTextInput extends State<CustomTextInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isInsideHashtag = false;
  int _hashtagStart = -1;
  int _hashtagEnd = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onInvisTextChanged() {
    // String text = _controller.text;

    // if ('"'.allMatches(text).length == 2) {
    //   _controller.text = text.replaceFirst('"', '‎').replaceFirst('"', '‎');
    // }
    //     if ('‎'.allMatches(text).length % 2 != 0) {
    //   _controller.text = text.replaceAll('‎', '"');
    // }
  }

  void _onTextChanged() {
    String text = _controller.text;
    int cursorPos = _controller.selection.baseOffset;

    if (text.contains('#')) {
      int hashPos = text.indexOf('#');
      if (cursorPos > hashPos) {
        _hashtagStart = hashPos;
        _hashtagEnd = _findHashtagEnd(text, hashPos);
        setState(() {
          _isInsideHashtag =
              cursorPos > _hashtagStart && cursorPos <= _hashtagEnd;
        });
      } else {
        setState(() {
          _isInsideHashtag = false;
        });
      }
    } else {
      setState(() {
        _isInsideHashtag = false;
      });
    }
  }

  int _findHashtagEnd(String text, int start) {
    int spacePos = text.indexOf(' ', start);
    int quoteStartPos = text.indexOf('"', start);
    // int invisStartPos = text.indexOf('‎', start);
    int quoteEndPos = -1;
    // int invisEndPos = -1;
    if (quoteStartPos != -1) {
      quoteEndPos = text.indexOf('"', quoteStartPos + 1);
    }
    // if (invisStartPos != -1) {
    //   invisEndPos = text.indexOf('‎', invisStartPos + 1);
    // }
    
    // if (invisStartPos != -1 && invisEndPos != -1 && invisEndPos > start) {
    //   return invisEndPos + 1;
    // }
    if (quoteStartPos != -1 && quoteEndPos != -1 && quoteEndPos > start) {
      return quoteEndPos + 1;
    }
    
    if (spacePos == -1) {
      return text.length;
    }
    return spacePos;
  }

  void _onFocusChanged() {
    setState(() {
      _isInsideHashtag = _focusNode.hasFocus && _isInsideHashtag;
    });
  }

  @override
  Widget build(BuildContext context) {
    String text = _controller.text;
    List<TextSpan> spans = [];
    int start = 0;

    // RegExp exp = RegExp(r'#[\w]+|"(?:([^"]|[^\u200E]))*"');
    RegExp exp = RegExp(r'#[\w]+|"(?:[^"])*"');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    for (RegExpMatch match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
            text: text.substring(start, match.start),
            style: const TextStyle(color: Colors.black)));
      }
      String matchedText = text.substring(match.start, match.end);
      spans.add(TextSpan(
          text: matchedText, // .replaceAll('"', '‎'),
          style: TextStyle(
              color: Colors.red,
              backgroundColor:
                  _isInsideHashtag ? Colors.green : Colors.amber)));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(
          text: text.substring(start, text.length),
          style: const TextStyle(color: Colors.black)));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _onInvisTextChanged();
                });
              },
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.purple,
                  height: 1.2,
                  fontFamily: 'Courier',
                  letterSpacing: 1),
              maxLines: 1,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.all(8),
                hintText: '',
                hintStyle: TextStyle(color: Colors.black),
              ),
              cursorColor: _isInsideHashtag ? Colors.red : Colors.blue,
              buildCounter: (context,
                      {required currentLength,
                      maxLength,
                      required isFocused}) =>
                  null,
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                    RegExp(r'[\u0000-\u001F\u007F-\u009F]')),
              ],
              key: const Key("Vis"),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 12.5, bottom: 8, left: 8, right: 8),
            child: IgnorePointer(
              child: SingleChildScrollView(
                key: const Key("Invis"),
                scrollDirection: Axis.horizontal,
                controller: _scrollController, // Use the same ScrollController
                child: RichText(
                  softWrap: false,
                  text: TextSpan(
                      children: spans,
                      style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.pink,
                          height: 1.2,
                          fontFamily: 'Courier',
                          letterSpacing: 1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }
}
