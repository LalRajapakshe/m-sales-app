import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String tittle;

  const TabItem({super.key, required this.tittle});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tittle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
