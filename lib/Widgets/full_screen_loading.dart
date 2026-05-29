import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 100,
        child: SpinKitRipple(
          size: 80,
          borderWidth: 10,
          color: Colors.orange,
        ),
      ),
    );
  }
}
