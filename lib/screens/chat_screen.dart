import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bubble/bubble.dart';                // ← new
import 'package:stoic_hotline/core/theme/text_styles.dart';
import 'package:stoic_hotline/models/philosopher.dart';
import 'quote_screen.dart';

class ChatScreen extends StatefulWidget {
  final Philosopher philosopher;

  const ChatScreen({
    super.key,
    required this.philosopher,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<String>> _quotesFuture;
  String _displayedQuote = '';

  // new: whether to show the two bubble buttons
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _quotesFuture = _loadQuotes();
  }

  Future<List<String>> _loadQuotes() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString(widget.philosopher.quotes);
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((entry) {
      final q = entry['quote'];
      return (q is List) ? q.join('\n\n') : q.toString();
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _consult() async {
    final quotes = await _quotesFuture;
    if (quotes.isNotEmpty) {
      final random = Random().nextInt(quotes.length);
      setState(() {
        _displayedQuote = quotes[random];
      });
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // adjust this if your image has a different height
    const double _imageHeight = 400;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7CC),
      body: SafeArea(
        child: Stack(
          children: [
            // ---- Main content (textfield + quote) ----
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Describe your problem...',
                      hintStyle: AppTextStyles.titleStyle.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    style: AppTextStyles.titleStyle.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: null,
                    maxLength: 200,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),

                  const SizedBox(height: 32),
                  const Spacer(),

                  if (_displayedQuote.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 120.0),
                      child: Text(
                        _displayedQuote,
                        style: AppTextStyles.bodyStyle,
                      ),
                    ),
                ],
              ),
            ),

            // ---- Philosopher image ----
                    Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showOptions = !_showOptions;
              });
            },
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 1,
              child: SizedBox(
                height: _imageHeight,
                child: Image.asset(
                  widget.philosopher.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ---- Speech bubbles (pop-in + ripple) ----
        // Back button
        Positioned(
          bottom: _imageHeight + 24,
          left: 40,
          child: AnimatedScale(
            scale: _showOptions ? 1 : 0,
            duration: Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Bubble(
              nip: BubbleNip.rightBottom,
              elevation: 1,
              color: Colors.white,
              child: Material(
                color: Colors.transparent, // let the Bubble draw the white bg
                child: InkWell(
                  onTap: _goBack,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Back', style: AppTextStyles.buttonStyle),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Consult button
        Positioned(
          bottom: _imageHeight + 24,
          right: 40,
          child: AnimatedScale(
            scale: _showOptions ? 1 : 0,
            duration: Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Bubble(
              nip: BubbleNip.leftBottom,
              elevation: 1,
              color: Colors.white,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QuoteScreen(
                          philosopher: widget.philosopher,
                          userInput: _controller.text,
                        ),
                      ),
                    );
                    setState(() {
                      _showOptions = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Consult',style: AppTextStyles.buttonStyle),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
        ),
      ),
    );
  }
}
