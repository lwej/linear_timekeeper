import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linear_timekeeper/main.dart'; // TODO: Remove later (For the silly debugMode variable)
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/utils/progress_bar_utils.dart';
import 'package:linear_timekeeper/theme/custom_timer_colors.dart';

class DotWidget extends StatelessWidget {
  final double size;
  final Color color;

  const DotWidget({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class DottedProgressBar extends StatefulWidget {
  const DottedProgressBar({
    super.key,
    required this.timerData,
    this.blinkDuration = const Duration(milliseconds: 500),
    this.blinkTotalDuration = const Duration(seconds: 3),
    this.enableBlink = true,
  });

  final TimerData timerData;
  final Duration blinkDuration;
  final Duration blinkTotalDuration;
  final bool enableBlink;

  @override
  State<DottedProgressBar> createState() => _DottedProgressBarState();
}

class _DottedProgressBarState extends State<DottedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  Timer? _blinkTimer;
  bool _blinking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.blinkDuration,
      vsync: this,
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  bool get _shouldBlink =>
      shouldBlinkProgressBar(widget.timerData.timerController);

  void _startBlinking() {
    if (_blinking) return;
    if (!widget.enableBlink) return;
    _blinking = true;
    _controller.forward();
    _blinkTimer?.cancel();
    _blinkTimer = Timer(widget.blinkTotalDuration, () {
      _stopBlinking();
      if (mounted) setState(() {});
    });
  }

  void _stopBlinking() {
    _controller.stop();
    _controller.value = 1.0;
    _blinkTimer?.cancel();
    _blinking = false;
  }

  @override
  void didUpdateWidget(covariant DottedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldBlink) {
      _startBlinking();
    } else {
      _stopBlinking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerData = widget.timerData;
    final CustomTimerColors customColors =
        Theme.of(context).extension<CustomTimerColors>()!;
    final int maxTotalDots = timerData.dotsPerMinute
        ? timerData.timerController.maxPresetMinutes
        : 20;
    final int activeDots = calculateActiveDots(
      dotsPerMinute: timerData.dotsPerMinute,
      presets: timerData.timerController.presetMinutesList,
      maxTotalDots: maxTotalDots,
      totalDurationMinutes: timerData.timerController.maxPresetMinutes,
      selectedMinutes: timerData.timerController.duration.inSeconds ~/ 60,
      remainingSeconds: timerData.timerController.remainingTime.inSeconds,
      timerState: timerData.timerController.timerState,
      debugMode: debugMode,
    );

    // Build dots only when timer state or color changes
    final List<Widget> dotWidgets = List.generate(maxTotalDots, (int index) {
      final Color dotColor = (index < activeDots)
          ? customColors.activeDotColor
          : customColors.inactiveDotColor;
      return Expanded(
        child: DotWidget(
          size: timerData.dotSize,
          color: dotColor,
        ),
      );
    });

    Widget dotsRow = SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: dotWidgets,
      ),
    );

    // Only animate opacity when timer has stopped and blinking is enabled
    if (_shouldBlink &&
        widget.enableBlink &&
        timerData.timerController.timerState == TimerState.stopped) {
      return AnimatedBuilder(
        animation: _opacityAnim,
        builder: (context, child) {
          return Opacity(
            opacity: _blinking ? _opacityAnim.value : 1.0,
            child: child,
          );
        },
        child: dotsRow,
      );
    } else {
      return dotsRow;
    }
  }
}
