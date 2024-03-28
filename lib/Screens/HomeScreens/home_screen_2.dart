import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/user_info.dart';
import 'package:soaproject/Widgets/Record/record_listtile_widget_real.dart';
import 'package:soaproject/Widgets/Record/calendar_badge_widget.dart';
import 'package:soaproject/Widgets/divider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:soaproject/Provider/record.dart';

class RecordCalendarScreen extends StatefulWidget {
  static const routeName = 'HomeScreen2';
  final User? user;
  final double height, width;
  const RecordCalendarScreen({
    this.user,
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  State<RecordCalendarScreen> createState() => _RecordCalendarScreenState();
}

class _RecordCalendarScreenState extends State<RecordCalendarScreen> {
  late List<Event> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, List<Event>> _events = {};

  List<Event> _getEventsForDay(DateTime selectedday) {
    String date = DateFormat('yyyy-MM-dd').format(selectedday);
    if (_events[date] == null) {
      return [];
    } else if (_events[date]!.length == 1) {
      return _events[date]!;
    }
    List<Event> _tempList = _events[date]!;
    _tempList.sort(((a, b) {
      return a.date.difference(b.date).inMinutes;
    }));
    return _tempList.reversed.toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      setState(() {
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Provider.of<Record>(context, listen: false).downloadRecords(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    print('page 2');
    UserInformations _userInfo = UserInformations(nickname: '손님');
    if (widget.user != null) {
      _userInfo = Provider.of<UserInfoprovider>(context, listen: false)
          .getUserInformagions;
    }
    _events = Provider.of<Record>(context).eventList;
    _selectedDay ??= DateTime.now();
    _selectedEvents = _getEventsForDay(_selectedDay!);

    return Padding(
      padding: const EdgeInsets.only(
        right: 24,
        left: 24,
        top: 12,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              '${_userInfo.nickname}의 기록',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            const MyDivider(),
            TableCalendar(
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, thisdate, events) {
                  List<Event> thatdayevents = _getEventsForDay(thisdate);
                  if (thatdayevents.isNotEmpty) {
                    return BuildEventsMarker(
                      date: thisdate,
                      events: thatdayevents,
                    );
                  }
                  return null;
                },
              ),
              locale: 'ko_KR',
              weekendDays: const [7],
              rowHeight: 40,
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              headerStyle: const HeaderStyle(
                headerPadding: EdgeInsets.symmetric(vertical: 4),
                titleTextStyle: TextStyle(fontSize: 18),
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: const CalendarStyle(
                isTodayHighlighted: false,
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1568B3),
                ),
                canMarkersOverflow: true,
                outsideDaysVisible: false,
                cellMargin: EdgeInsets.all(2),
                defaultTextStyle: TextStyle(fontSize: 18),
                weekendTextStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 12),
            const MyDivider(),
            _calendarFormat == CalendarFormat.week
                ? SizedBox(
                    height: 28,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          _calendarFormat = CalendarFormat.month;
                        });
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  )
                : const SizedBox(height: 4),
            Consumer<Record>(
              builder: (context, value, child) => GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dy < -5 &&
                      _calendarFormat == CalendarFormat.month) {
                    setState(() {
                      _calendarFormat = CalendarFormat.week;
                    });
                  }
                },
                child: SizedBox(
                  height: _calendarFormat == CalendarFormat.month
                      ? widget.height - 440
                      : widget.height - 332,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: _calendarFormat == CalendarFormat.month
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      Event _inputevent = _selectedEvents[index];
                      return RecordListtileWidget(
                        event: _inputevent,
                        user: widget.user,
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_calendarFormat == CalendarFormat.week)
              const SizedBox(height: 4),
            if (_calendarFormat == CalendarFormat.week) const MyDivider(),
            if (_calendarFormat == CalendarFormat.week)
              const SizedBox(height: 4),
            if (_calendarFormat == CalendarFormat.week)
              const BottomExplanationWidget()
          ],
        ),
      ),
    );
  }
}

class BottomExplanationWidget extends StatelessWidget {
  const BottomExplanationWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: const [
          CircleAvatar(
            backgroundColor: Color(0xFF1568B3),
            radius: 4,
          ),
          Text(
            ' : 복용 기록   ',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 12,
            ),
          ),
          CircleAvatar(
            backgroundColor: Color(0xff4B990F),
            radius: 4,
          ),
          Text(
            ' : 식사 기록   ',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 12,
            ),
          ),
          CircleAvatar(
            backgroundColor: Color(0xffFF8D66),
            radius: 4,
          ),
          Text(
            ' : 대소변 기록',
            style: TextStyle(
              color: Colors.black38,
              fontSize: 12,
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
