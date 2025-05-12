import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bubble/bubble.dart';
import 'package:stoic_hotline/core/theme/text_styles.dart';
import 'package:stoic_hotline/models/philosopher.dart';
import 'home_screen.dart';

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
  void goHome(){
  //create "Go home?" pop-up with yes or cancel options. "Yes navigates back to homepage with navigator pushAndRemoveUntil"
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text('Go home?', style: AppTextStyles.titleStyle.copyWith(fontSize: 20), ),
        actions: <Widget>[
          Center(
            child:           
                TextButton(
                child: Text('Cancel',style: AppTextStyles.buttonStyle,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

          ),
          Center(          
            child:
              TextButton(
              child: Text('Yes',style: AppTextStyles.buttonStyle,),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),


        ],
      );
    },
  );

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
            // ---- Philosopher image ----
          Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                goHome();
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
          ],
        
        ),
      ),
    );
  }
}
