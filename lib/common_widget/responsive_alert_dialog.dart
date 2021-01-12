import 'dart:io';

import 'package:canli_sohbet_app/common_widget/platform_duyarli_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveAlertDialog extends PlatformDuyarliWidget {
  final String title;
  final String content;
  final String mainButton;
  final String cancelButton;

  ResponsiveAlertDialog(
      {@required this.title,
      @required this.content,
      @required this.mainButton,
      this.cancelButton});

  Future<bool> show(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context, builder: (context) => this)
        : await showDialog<bool>(context: context, builder: (context) => this, barrierDismissible: false);
  }

  @override
  Widget buildAndroidWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _setDialogButton(context),
    );
  }

  @override
  Widget buildIOSWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _setDialogButton(context),
    );
  }

  List<Widget> _setDialogButton(BuildContext context) {
    final allButtons = <Widget>[];

    if (Platform.isIOS) {
      if (cancelButton != null) {
        allButtons.add(
          CupertinoDialogAction(
            child: Text(cancelButton),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      }
      allButtons.add(
        CupertinoDialogAction(
          child: Text(mainButton),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    } else {
      if (cancelButton != null) {
        allButtons.add(
          FlatButton(
            child: Text(cancelButton),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        );
      }
      allButtons.add(
        FlatButton(
          child: Text(mainButton),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      );
    }

    return allButtons;
  }
}
