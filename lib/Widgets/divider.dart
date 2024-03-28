import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  final double? length;
  const MyDivider({this.length, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      height: 1,
      width: length ?? 240,
    );
  }
}
