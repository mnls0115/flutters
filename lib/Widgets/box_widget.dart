import 'package:flutter/cupertino.dart';

class BoxWidget extends StatelessWidget {
  final String title, unit;
  final num? value;
  const BoxWidget({
    required this.title,
    required this.unit,
    this.value,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 36,
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              value == null ? '- $unit' : '$value $unit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }
}
