import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading {
  void startLoading(BuildContext context) {
    log("LOADING START");
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black45,
      context: context,
      builder: (context) {
        return const Center(
            child: SpinKitRipple(
          size: 80,
          borderWidth: 10,
          color: Colors.orange,
        ));
      },
    );
  }

  void stopLoading(BuildContext context) {
    log("LOADING STOP");
    Navigator.of(context).pop();
  }
}
