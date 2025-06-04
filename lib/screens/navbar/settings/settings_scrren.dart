import 'package:education_app/constants/color.dart';
import 'package:education_app/constants/size.dart';
import 'package:education_app/constants/sub_title.dart';
import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';
import 'package:education_app/screens/authentication/login_screen.dart';
import 'package:education_app/screens/profile-personly/editprofile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../constants/font_weight_helper.dart';
import '../../profile-personly/bills/bills_screen.dart';
import '../../profile-personly/profile_personly.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthFailureState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        } else if (state is AuthLoggedOutState) {
                          // Navigate to login screen after logout
                          navigateAndFinish(context, const LogIn());
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoadingState) {
                          return const CircularProgressIndicator();
                        } else if (state is AuthSuccessState) {
                          return Column(
                            children: [
                              SizedBox(
                                width: 100.w,
                                height: 100.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: state.user!.info?.photo != null
                                      ? Image.network(
                                          'https://barraband.net/storage/${state.user!.info?.photo}',
                                          fit: BoxFit.cover,
                                        )
                                      : const Image(
                                          image: NetworkImage(
                                            'https://img.freepik.com/premium-photo/memoji-happy-man-white-background-emoji_826801-6840.jpg?size=626&ext=jpg&uid=P52758974&ga=GA1.1.1930941175.1705394112&semt=sph',
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  state.user!.info?.name ?? 'User Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  state.user!.info?.email ?? 'user@example.com',
                                  style: const TextStyle(
                                    color: Color(0xfffbdb4c),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Text(
                            'Failed to load user data',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    GestureDetector(
                      onTap: () => navigateTo(context, const EditProfile()),
                      child: Container(
                        width: 200.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: const Color(0xfffbdb4c),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: SubTitle(
                            text: 'تحديث البيانات',
                            size: 25,
                            color: Colors.black,
                            weight: FontWeightHelper.medium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    // Container(
                    //   width: 300.w,
                    //   height: 50.h,
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xfffbdb4c),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: customProfile(
                    //     title: 'الاعددات',
                    //     icon: LineAwesomeIcons.cog,
                    //     textColor: Colors.black,
                    //     onPress: () {},
                    //   ),
                    // ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      width: 300.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: const Color(0xfffbdb4c),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: customProfile(
                        title: 'بيانات الطالب',
                        icon: Icons.person_outline,
                        textColor: Colors.black,
                        onPress: () {
                          navigateTo(context, const ProfilePersonly());
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      width: 300.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: const Color(0xfffbdb4c),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: customProfile(
                        title: 'الفواتير',
                        icon: LineAwesomeIcons.money_bill,
                        textColor: Colors.black,
                        onPress: () {
                          navigateTo(context, BillsScreen());
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: 300.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: const Color(0xfffbdb4c),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: customProfile(
                        title: 'تسجيل الخروج',
                        icon: Icons.logout,
                        textColor: Colors.black,
                        onPress: () {
                          // BlocProvider.of<AuthCubit>(context).logout();
                          logOut(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60.dg, left: 270.sp),
                      child: Image.asset(
                        'assets/icons/prp3.png',
                        width: 80.w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class customProfile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;
  const customProfile({
    required this.title,
    required this.icon,
    required this.onPress,
    this.textColor,
    this.endIcon = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: ListTile(
        leading: SizedBox(
          width: 30.w,
          height: 30.h,
          child: Icon(
            icon,
            color: textColor,
            size: 30,
          ),
        ),
        title: SubTitle(
          text: title,
          size: 25,
          color: Colors.black,
          weight: FontWeightHelper.medium,
        ),
        trailing: endIcon
            ? SizedBox(
                width: 30.w,
                height: 30.h,
                child: GestureDetector(
                  onTap: onPress,
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              )
            : null,
      ),
    );
  }
}
