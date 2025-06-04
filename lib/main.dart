import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:education_app/constants/constans.dart';
import 'package:education_app/constants/network/local_network.dart';
import 'package:education_app/layout/navbar_cubit/cubit/navbar_cubit.dart';
import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';
import 'package:education_app/screens/authentication/login_screen.dart';
import 'package:education_app/screens/home/cubit/main_cubit.dart';
import 'package:education_app/screens/navbar/nav_bar.dart';
import 'package:education_app/screens/profile-personly/cubit/profile_cubit.dart';
import 'package:education_app/screens/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheNetwork.cacheInitialization();
  Widget widget;
  // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  token = await CacheNetwork.getCacheData(key: "token");

  if (token != null && token != '') {
    widget = MyNavbarBottm();
  } else {
    widget = LogIn();
  }

  print("Your Exbended Token is : $token");
  runApp(MyApp(
    startWidget: widget,
  ));
}

class MyApp extends StatelessWidget {
  final Widget startWidget;

  MyApp({required this.startWidget});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (BuildContext context) => NavbarCubit()),
          BlocProvider(create: (context) => AuthCubit()..fetchUserDetails()),
          BlocProvider(create: (context) => ProfileCubit()..fetchPackages()),
          BlocProvider(create: (context) => MainCubit()..fetchCategories()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'),
          ],
          debugShowCheckedModeBanner: false,
          title: 'Education App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'ArbFONTS',
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              displayMedium: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          home: AnimatedSplashScreen(
            splash: const SplashScreen(),
            nextScreen: startWidget,
            splashIconSize: double.infinity,
            animationDuration: const Duration(seconds: 3),
            splashTransition: SplashTransition.fadeTransition,
          ),
        ),
      ),
    );
  }
}
