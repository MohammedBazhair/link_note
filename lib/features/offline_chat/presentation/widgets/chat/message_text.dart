import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';

class MessageText extends StatefulWidget {
  const MessageText({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });
  final String text;
  final DateTime time;
  final bool isMe;

  @override
  State<MessageText> createState() => _MessageTextState();
}

class _MessageTextState extends State<MessageText> {
  TapGestureRecognizer? _gestureRecognizer;

  String showedText = '';
  int offset = 0;

  bool get isShowMore => widget.text.length != showedText.length;

  @override
  void initState() {
    super.initState();
    _gestureRecognizer = TapGestureRecognizer()..onTap = addMoreText;

    offset = min(1000, widget.text.length);
    showedText += widget.text.substring(0, offset);
  }

  void addMoreText() {
    final nextOffset = offset + 1000;
    final endOffset = min(nextOffset, widget.text.length);
    setState(() {
      showedText += widget.text.substring(offset, endOffset);
      offset = endOffset;
    });
  }

  @override
  void dispose() {
    _gestureRecognizer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.end,
      children: [
        Text.rich(
          TextSpan(
            text: isShowMore ? '$showedText...' : showedText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: widget.isMe
                  ? const Color(0xFFFFFFFF)
                  : const Color(0xFFF1F0F4),
            ),
            children: [
              if (isShowMore)
                TextSpan(
                  text: 'اقرأ المزيد',
                  style: const TextStyle(
                    fontSize: 11,

                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                  recognizer: _gestureRecognizer,
                ),
            ],
          ),
        ),

        Text(
          widget.time.formattedChatTime,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: -0.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
