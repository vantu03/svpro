import 'dart:async';
import 'package:flutter/material.dart';

class DotLoadingText extends StatefulWidget {
  final String text;
  final Duration interval;
  final String dotChar;
  final int maxDots;
  final TextStyle? style;

  const DotLoadingText({
    super.key,
    this.text = 'Loading',
    this.interval = const Duration(milliseconds: 200),
    this.dotChar = '.',
    this.maxDots = 3,
    this.style,
  });

  @override
  State<DotLoadingText> createState() => DotLoadingTextState();
}

class DotLoadingTextState extends State<DotLoadingText> {
  int dotCount = 0;
  late final Timer timer;
  late final double maxWidth;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(widget.interval, (_) {
      setState(() {
        dotCount = (dotCount + 1) % (widget.maxDots + 1);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    maxWidth = _calculateMaxWidth(context);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  double _calculateMaxWidth(BuildContext context) {
    final fullText = widget.text + (widget.dotChar * widget.maxDots);
    final textPainter = TextPainter(
      text: TextSpan(text: fullText, style: widget.style ?? DefaultTextStyle.of(context).style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final dots = widget.dotChar * dotCount;

    return SizedBox(
      width: maxWidth,
      child: Text(
        '${widget.text}$dots',
        style: widget.style,
      ),
    );
  }
}
