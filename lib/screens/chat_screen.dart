import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bubble/bubble.dart';
import 'package:stoic_hotline/core/theme/text_styles.dart';
import 'package:stoic_hotline/core/theme/app_theme.dart';
import 'package:stoic_hotline/models/philosopher.dart';
import 'package:animations/animations.dart';
import 'quote_screen.dart';
import '../core/sound_effects_controller.dart';

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
  final FocusNode _focusNode = FocusNode();
  final SoundEffectsController _soundEffectsController = SoundEffectsController();
  String _displayedQuote = '';
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    // After the first frame, focus the text field so the keyboard pops up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _playButtonSoundAndGoBack() {
    _soundEffectsController.playButtonClick();
    _goBack();
  }

  @override
  Widget build(BuildContext context) {
    const double _imageHeight = 400;

    return Scaffold(
      // Don't resize the body when the keyboard appears—let it overlay
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFFF7CC),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content: text field + displayed quote
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
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

            // Philosopher image (tappable to toggle options)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: GestureDetector(
                onTap: () {
                  _soundEffectsController.playButtonClick();
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

            // Back button bubble
            Positioned(
              bottom: _imageHeight + 24,
              left: 40,
              child: AnimatedScale(
                scale: _showOptions ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                child: Bubble(
                  nip: BubbleNip.rightBottom,
                  elevation: 1,
                  color: Theme.of(context).colorScheme.primary,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _playButtonSoundAndGoBack,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text('Back', style: AppTextStyles.buttonStyle),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Consult button bubble + open container
            Positioned(
              bottom: _imageHeight + 24,
              right: 40,
              child: OpenContainer(
                transitionDuration: const Duration(milliseconds: 400),
                closedElevation: 0,
                closedColor: Colors.transparent,
                clipBehavior: Clip.none,
                tappable: false,
                closedBuilder: (context, openContainer) {
                  return AnimatedScale(
                    scale: _showOptions ? 1 : 0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    child: Bubble(
                      nip: BubbleNip.leftBottom,
                      elevation: 1,
                      color: Theme.of(context).colorScheme.primary,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () {
                            _soundEffectsController.playButtonClick();
                            if (_controller.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter a problem.',
                                    style: AppTextStyles.subtitleStyle,
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            } else {
                              setState(() => _showOptions = false);
                              openContainer();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text('Consult', style: AppTextStyles.buttonStyle),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                openBuilder: (context, _) => QuoteScreen(
                  philosopher: widget.philosopher,
                  userInput: _controller.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
