import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import '../../constants/color.dart';
import '../../constants/icons.dart';
import '../../constants/size.dart';
import '../../layout/navbar_cubit/cubit/navbar_cubit.dart';

class MyNavbarBottm extends StatelessWidget {
  const MyNavbarBottm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavbarCubit, NavbarState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = NavbarCubit.get(context);
        return WillPopScope(
          onWillPop: () async {
            // إذا كان المستخدم قد ضغط على زر العودة مرتين
            if (cubit.canExit) {
              return true; // الخروج من التطبيق
            } else {
              // في حالة الضغط مرة واحدة
              cubit.showExitToast(context);
              return false; // لا تخرج من التطبيق
            }
          },
          child: Scaffold(
            extendBody: true,
            body: cubit.bottmScreens[cubit.currentIndex],
            bottomNavigationBar: MoltenBottomNavigationBar(
              barColor: kPrimaryLight,
              domeCircleColor: kPrimaryColor,
              domeCircleSize: 25,
              selectedIndex: cubit.currentIndex,
              onTabChange: (index) {
                cubit.changeBottom(index);
              },
              tabs: [
                MoltenTab(
                  icon: Image.asset(
                    icFeaturedOutlined,
                    height: kBottomNavigationBarItemSize,
                    color: Colors.white,
                  ),
                ),
                // أضف المزيد من التبويبات هنا حسب الحاجة
                MoltenTab(
                  icon: Image.asset(
                    'assets/icons/profile.png',
                    height: kBottomNavigationBarItemSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
