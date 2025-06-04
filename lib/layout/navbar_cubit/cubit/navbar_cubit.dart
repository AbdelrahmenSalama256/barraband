import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../screens/home/base_screen.dart';
import '../../../screens/navbar/settings/settings_scrren.dart';

part 'navbar_state.dart';

class NavbarCubit extends Cubit<NavbarState> {
  NavbarCubit() : super(NavbarInitial());

  static NavbarCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  bool canExit = false; // متغير للحفاظ على حالة الخروج

  List<Widget> bottmScreens = [
    const BaseScreen(),
    // const MyLearning(),
    // const WishlistScreen(),
    const Profile(),
  ];

  void changeBottom(int index) {
    currentIndex = index;
    emit(NavbarBottm());
  }

  void navigateToFirstIndex(BuildContext context) {
    currentIndex = 0; // العودة إلى الفهرس الأول
    emit(NavbarBottm()); // اطلاق الحدث لتحديث الواجهة
  }

  void showExitToast(BuildContext context) {
    if (!canExit) {
      canExit = true; // تفعيل إمكانية الخروج
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("للخروج، اضغط مرتين للعودة"),
          duration: const Duration(seconds: 2),
        ),
      );

      // إعادة تعيين حالة الخروج بعد مدة
      Future.delayed(const Duration(seconds: 2), () {
        canExit = false; // إعادة تعيين الحالة
      });
    }
  }
}
