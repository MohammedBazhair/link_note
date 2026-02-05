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
  bool get isShowMore => widget.text.length != showedText.length;

  String showedText = '';
  int offset = 0;
  @override
  void initState() {
    super.initState();
    showedText += widget.text.substring(0, 1000);
  }

  void addMoreText() {
    final nextOffset = offset + 1000;
    final endOffset = nextOffset > widget.text.length
        ? widget.text.length
        : nextOffset;
    setState(() {
      offset = endOffset;
      showedText += widget.text.substring(offset, endOffset);
    });
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
                  recognizer: TapGestureRecognizer()..onTap = addMoreText,
                ),
            ],
          ),
        ),

        Text(
          widget.time.formatedChatTime,
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
