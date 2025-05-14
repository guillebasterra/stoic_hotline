// lib/screens/quote_screen.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:bubble/bubble.dart';
import 'package:stoic_hotline/core/theme/app_theme.dart';
import 'package:stoic_hotline/core/theme/text_styles.dart';
import 'package:stoic_hotline/models/philosopher.dart';
import 'home_screen.dart';
import '../core/sound_effects_controller.dart';

class QuoteScreen extends StatefulWidget {
  final Philosopher philosopher;
  final String userInput;

  const QuoteScreen({
    super.key,
    required this.philosopher,
    required this.userInput,
  });

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final SoundEffectsController _soundEffectsController = SoundEffectsController();
  late final Dio _dio;
  late final CancelToken _cancelToken;
  String? _quote;
  String? _source;
  bool _isLoading = true;

  // NEW: pages for in-place pagination
  List<String> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    _dio = Dio(BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com',
      connectTimeout: const Duration(milliseconds: 15000),
      receiveTimeout: const Duration(milliseconds: 15000),
      headers: {
        'Authorization': 'Bearer ${dotenv.env['GEMINI_API_KEY'] ?? ''}',
        'Content-Type': 'application/json',
      },
    ))
      ..interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
      ));
    _fetchGeminiQuote();
  }

  @override
  void dispose() {
    _cancelToken.cancel('User left');
    _dio.close(force: true);
    super.dispose();
  }

  Future<void> _fetchGeminiQuote() async {
    final prompt = '''
Here is a problem I am dealing with: "${widget.userInput}".
Can you give me a real quote from the philosopher "${widget.philosopher.name}"
that would provide wisdom in response to this problem?
Please return JSON like:
{
  "quote": "…",
  "source": "…"
}
Ensure it's a real quote. Do not hallucinate.
''';

    final payload = {
      'model': 'gemini-2.0-flash',
      'messages': [
        {'role': 'system', 'content': 'You only return valid, real quotes.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.2,
    };

    try {
      final response = await _dio.post(
        '/v1beta/openai/chat/completions',
        data: payload,
        cancelToken: _cancelToken,
      );

      final data = response.data as Map<String, dynamic>;
      final raw = data['choices'][0]['message']['content'] as String;
      final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```', multiLine: true);
      final match = fence.firstMatch(raw);
      final jsonString = match != null ? match.group(1)!.trim() : raw.trim();
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        _quote      = parsed['quote']  as String?;
        _source     = parsed['source'] as String?;
        _isLoading  = false;
        // reset pagination
        _pages.clear();
        _currentPage = 0;
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
                        e.type == DioExceptionType.receiveTimeout;
      if (!mounted) return;
      setState(() {
        _quote     = isTimeout
            ? 'Request timed out. Please try again.'
            : 'Error: ${e.message}';
        _isLoading = false;
        _pages.clear();
        _currentPage = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _quote     = 'Error parsing response: $e';
        _isLoading = false;
        _pages.clear();
        _currentPage = 0;
      });
    }
  }

  void _goHome() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(child:Text(
          'Go home?',
          style: AppTextStyles.buttonStyle.copyWith(fontSize: 40),
        ),
        ),
        
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
            children: [
              TextButton(
                child: Text('Cancel', style: AppTextStyles.buttonStyle),
                onPressed: () {
                  _soundEffectsController.playButtonClick();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes', style: AppTextStyles.buttonStyle),
                onPressed: () {
                  _soundEffectsController.playButtonClick();
                  _cancelToken.cancel('User navigated home');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

List<String> _paginateText(
    String text, TextStyle style, double maxWidth, double maxHeight) {
  final pages = <String>[];
  final tp = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: null,
  );

  int start = 0;
  final words = text.split(' '); // Split the text into words
  while (start < words.length) {
    int low = start, high = words.length;
    String candidate = '';

    // Binary search to find the largest chunk of text that fits
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      candidate = words.sublist(start, mid).join(' ');
      tp.text = TextSpan(text: candidate, style: style);
      tp.layout(maxWidth: maxWidth);

      if (tp.height <= maxHeight) {
        low = mid; // Candidate fits, try a larger chunk
      } else {
        high = mid - 1; // Candidate doesn't fit, try a smaller chunk
      }
    }

    // Add the largest fitting chunk to the pages
    candidate = words.sublist(start, low).join(' ');
    pages.add(candidate);

    // Move the start pointer to the next word
    start = low;
  }

  return pages;
}

  @override
Widget build(BuildContext context) {
  const imageHeight = 400.0;

  return Scaffold(
    backgroundColor: const Color(0xFFFFF7CC),
    body: SafeArea(
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.only(bottom: imageHeight),
            child: Column(
              children: [
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  LayoutBuilder(builder: (context, constraints) {
                    // determine the text‐box size roughly matching the old dialog
                    final boxWidth = constraints.maxWidth - 32;
                    final boxHeight = MediaQuery.of(context).size.height * 0.36;
                    final textStyle = AppTextStyles.subtitleStyle.copyWith(fontSize: 29);

                    // On first build after load, paginate:
                    if (_pages.isEmpty && _quote != null) {
                      _pages = _paginateText(
                        _quote!,
                        textStyle,
                        boxWidth,
                        boxHeight - 60, // reserve for controls
                      );
                      _currentPage = 0;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Bubble(
                        color: AppTheme.lightTheme.colorScheme.surfaceBright,
                        nip: BubbleNip.no,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: boxWidth,
                              height: boxHeight - 60,
                              child: Text(
                                // if pagination worked, show the page, else fallback
                                (_pages.isNotEmpty
                                    ? _pages[_currentPage]
                                    : (_quote ?? 'No quote found.')),
                                style: textStyle,
                              ),
                            ),

                            // only show controls if more than one page
                            if (_pages.length > 1) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 0
                                        ? () {
                                            _soundEffectsController.playButtonClick();
                                            setState(() => _currentPage--);
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '${_currentPage + 1}/${_pages.length}',
                                    style: textStyle,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _currentPage < _pages.length - 1
                                        ? () {
                                            _soundEffectsController.playButtonClick();
                                            setState(() => _currentPage++);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],

                            if (_source != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '- ${_source!}',
                                style: AppTextStyles.subtitleStyle.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 26,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Philosopher image at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: 
                () {
                  _soundEffectsController.playButtonClick();
                  _goHome();
                },
              
              child: SizedBox(
                height: imageHeight,
                child: Image.asset(
                  widget.philosopher.image,
                  fit: BoxFit.contain,
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
