import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 2;
  static const double regular = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double full = 9999;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius regularBorder = BorderRadius.all(
    Radius.circular(regular),
  );
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullBorder = BorderRadius.all(
    Radius.circular(full),
  );
}
