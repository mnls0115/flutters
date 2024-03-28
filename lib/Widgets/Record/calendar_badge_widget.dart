import 'package:flutter/material.dart';
import 'package:soaproject/Provider/record.dart';

class BuildEventsMarker extends StatelessWidget {
  final DateTime date;
  final List<Event> events;
  const BuildEventsMarker({
    required this.date,
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('badge widget');
    int _drug = 0, _meal = 0, _toilet = 0;
    for (Event _temp in events) {
      if (_temp.recordType == 0) {
        _drug += 1;
        continue;
      } else if (_temp.recordType == 1) {
        _meal += 1;
        continue;
      } else {
        _toilet += 1;
        continue;
      }
    }

    return Stack(
      children: [
        if (_drug != 0)
          Badge(
            type: 0,
            counts: _drug,
          ),
        if (_meal != 0)
          Badge(
            type: 1,
            counts: _meal,
          ),
        if (_toilet != 0)
          Badge(
            type: 2,
            counts: _toilet,
          ),
      ],
    );
  }
}

class Badge extends StatelessWidget {
  final int type, counts;
  const Badge({
    Key? key,
    required this.type,
    required this.counts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: type == 0 ? 12 : 0,
      left: type == 2 ? 12 : 0,
      bottom: 4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: type == 0
              ? const Color(0xFF1568B3)
              : type == 1
                  ? const Color(0xff4B990F)
                  : const Color(0xffFF8D66),
        ),
        width: 4,
        height: 4,
      ),
    );
  }
}
