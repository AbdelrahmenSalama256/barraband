import 'package:education_app/constants/network/local_network.dart';
import 'package:education_app/screens/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

const kBottomNavigationBarItemSize = 20.0;
const kCategoryCardImageSize = 120.0;

void navigateTo(context, widget) => Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: widget,
      ),
    );

void navigateAndFinish(
  context,
  widget,
) =>
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: widget,
      ),
      (route) {
        return false;
      },
    );

void logOut(context) {
  CacheNetwork.removeData(
    key: 'token',
  ).then((value) {
    if (value) {
      navigateAndFinish(context, LogIn());
    }
  });
}
