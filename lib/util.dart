import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final RoundedRectangleBorder rounded30 = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(30),
);

final yMdHm = DateFormat("yyyy/MM/dd HH:mm");

Color tintColor(Color color, Color tint, double elevation) =>
    ElevationOverlay.applySurfaceTint(color, tint, elevation);

SystemUiOverlayStyle getNavOverlay(Color? color) => SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      statusBarColor: Colors.transparent,
    );
