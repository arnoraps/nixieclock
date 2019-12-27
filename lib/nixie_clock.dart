import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

// A digital clock using nixie images
class NixieClock extends StatefulWidget {
  const NixieClock(this.model);

  final ClockModel model;

  @override
  _NixieClockState createState() => _NixieClockState();
}

class _NixieClockState extends State<NixieClock>
    with SingleTickerProviderStateMixin {
  final _flexSperator = 1;
  final _flexDigit = 4;
  final _animationDuration = Duration(milliseconds: 1500);
  static const Cubic fastOutSlowIn = Cubic(0.4, 0.0, 0.2, 1.0);

  var _hour = "00";
  var _minute = "00";
  Animation<double> _animation;
  AnimationController _controller;
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: fastOutSlowIn,
    );

    _hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    _minute = DateFormat('mm').format(_dateTime);

    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(NixieClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  // Respond to model changes
  void _updateModel() {
    setState(() {});
  }

  // Get time, do animation and timer refresh
  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Start animation
      _controller.reset();
      _controller.forward();

      // Update once per minute
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  // Digit build (prev on bottom, current on top)
  Widget _getDigit(String digit, String prev) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "images/$prev.jpg",
          fit: BoxFit.fill,
          height: double.infinity,
        ),
        FadeTransition(
          opacity: _animation,
          child: Image.asset(
            "images/$digit.jpg",
            fit: BoxFit.fill,
            height: double.infinity,
          ),
        ),
      ],
    );
  }

  // Main container, with row with 4 digits and seperators
  @override
  Widget build(BuildContext context) {
    final _prevHour = _hour;
    final _prevMinute = _minute;
    _hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    _minute = DateFormat('mm').format(_dateTime);

    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SizedBox(),
            flex: _flexSperator,
          ),
          Expanded(
            child: _getDigit(_hour.substring(0, 1), _prevHour.substring(0, 1)),
            flex: _flexDigit,
          ),
          Expanded(
            child: _getDigit(_hour.substring(1), _prevHour.substring(1)),
            flex: _flexDigit,
          ),
          Expanded(
            child: SizedBox(),
            flex: _flexSperator,
          ),
          Expanded(
            child:
                _getDigit(_minute.substring(0, 1), _prevMinute.substring(0, 1)),
            flex: _flexDigit,
          ),
          Expanded(
            child: _getDigit(_minute.substring(1), _prevMinute.substring(1)),
            flex: _flexDigit,
          ),
          Expanded(
            child: SizedBox(),
            flex: _flexSperator,
          ),
        ],
      ),
    );
  }
}
