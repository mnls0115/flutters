import 'package:flutter/material.dart';

class DescriptionBuilder extends StatelessWidget {
  final List<String> descriptions;
  const DescriptionBuilder({
    required this.descriptions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('page description builder');

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: ((context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 2,
                backgroundColor: Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                descriptions[index],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        );
      }),
      itemCount: descriptions.length,
    );
  }
}
