import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bubble/bubble.dart';
import 'package:stoic_hotline/core/theme/text_styles.dart';
import 'package:stoic_hotline/models/philosopher.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          // Pushes the image to the bottom, input stays above it
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User input bubble
            if (widget.userInput.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Bubble(
                  nip: BubbleNip.no,
                  alignment: Alignment.center,
                  color: Colors.grey.shade200,
                  child: Text(
                    widget.userInput,
                    style: AppTextStyles.titleStyle.copyWith(fontSize: 18),
                  ),
                ),
              ),

            // Philosopher image
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ClipOval(
                child: widget.philosopher.image != null
                    ? Image.asset(
                        widget.philosopher.image,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
