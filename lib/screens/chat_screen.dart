import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stoic_hotline/core/theme/text_styles.dart';
import 'package:stoic_hotline/models/philosopher.dart';

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

  @override
  void initState() {
    super.initState();
    _quotesFuture = _loadQuotes();
  }

  Future<List<String>> _loadQuotes() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString(widget.philosopher.quotes);
    final List<dynamic> jsonList = json.decode(data);
    // Flatten each quote entry (which itself is a list of strings)
    return jsonList.map((entry) {
      final q = entry['quote'];
      if (q is List) {
        return q.join('\n\n');
      } else {
        return q.toString();
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "Hi, I'm ${widget.philosopher.name}.\nHow can I help you?",
                textAlign: TextAlign.center,
                style: AppTextStyles.titleStyle.copyWith(
                  fontSize: 50,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // Clickable philosopher image
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Image.asset(
                  widget.philosopher.image,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap the image to go back',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Problem description input
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'describe your problem...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Consult button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _consult,
                  child: const Text('consult'),
                ),
              ),
              const SizedBox(height: 32),

              // Displayed quote
              if (_displayedQuote.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _displayedQuote,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
