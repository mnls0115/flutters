import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:soaproject/Provider/record.dart';
import '/Screens/Records/record_input_screen.dart';

class RecordListtileWidget extends StatelessWidget {
  final Event event;
  final User? user;
  const RecordListtileWidget({
    required this.event,
    this.user,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('record listile widget');
    DateTime _date = event.date;
    String _title = event.title;
    int _type = event.recordType;
    Key _key = event.key;
    String _noon = _date.hour > 11 ? '오후' : '오전';

    return Dismissible(
      movementDuration: const Duration(milliseconds: 1),
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<Record>(context, listen: false).deleteRecord(
                        event: event,
                        user: user,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('확인'),
                  ),
                ],
                title: const Text('기록 삭제'),
                content: const Text('기록을 삭제하시겠습니까?'),
              );
            });
      },
      direction: DismissDirection.endToStart,
      background: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: const [
            Spacer(),
            Icon(
              Icons.delete,
              color: Color(0xFFB31568),
              size: 28,
            ),
          ],
        ),
      ),
      key: UniqueKey(),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(RecordScreen.routeName, arguments: {
            'date': _date,
            'title': _title,
            'type': _type,
            'key': _key,
            'isEditMode': false,
          });
        },
        child: Container(
          height: 76,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 6,
                backgroundColor: _type == 0
                    ? const Color(0xFF1568B3)
                    : _type == 1
                        ? const Color(0xff4B990F)
                        : const Color(0xffFF8D66),
              ),
              SizedBox(
                width: 160,
                child: Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  DateFormat('$_noon hh:mm').format(_date),
                  style: const TextStyle(
                    color: Colors.black45,
                  ),
                ),
              ),
              const SizedBox(
                width: 24,
                child: Icon(Icons.keyboard_arrow_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
