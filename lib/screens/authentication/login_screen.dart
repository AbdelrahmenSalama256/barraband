import 'package:education_app/constants/font_weight_helper.dart';
import 'package:education_app/constants/size.dart';
import 'package:education_app/constants/sub_title.dart';
import 'package:education_app/screens/authentication/ForgotPasswordPage.dart';
import 'package:education_app/screens/authentication/signup_scrren.dart';
import 'package:education_app/screens/authentication/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/color.dart';
import '../navbar/nav_bar.dart';
import 'cubit/auth_cubit.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController emailControlle = TextEditingController();
  final TextEditingController passwordControlle = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Image.asset(
                'assets/icons/ui2.png',
                fit: BoxFit.cover,
                height: 920.h,
              ),
              Positioned(
                top: 450.sp,
                left: 200.sp,
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccessState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تسجيل الدخول بنجاح!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      navigateAndFinish(context, const MyNavbarBottm());
                    } else if (state is AuthFailureState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoadingState) {
                      return const CircularProgressIndicator();
                    }
                    return Container(
                      width: 200.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: kPrimaryLight,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.white70,
                            offset: Offset(-2, -2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            BlocProvider.of<AuthCubit>(context).login(
                              email: emailControlle.text.trim(),
                              password: passwordControlle.text.trim(),
                            );
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: SubTitle(
                            text: 'دخول',
                            size: 30,
                            color: Colors.white,
                            weight: FontWeightHelper.medium,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 260.sp,
                right: 50.sp,
                left: 50.sp,
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AppTextFormField(
                        controller: emailControlle,
                        hintText: 'البريد الاكتروني',
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      AppTextFormField(
                        controller: passwordControlle,
                        hintText: 'كلمة المرور',
                        isObscureText: isObscureText,
                        suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isObscureText = !isObscureText;
                              });
                            },
                            child: Icon(isObscureText
                                ? Icons.visibility_off
                                : Icons.visibility)),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SubTitle(
                            text: 'ليس لديك حساب?',
                            size: 18,
                            color: darkBlue,
                            weight: FontWeightHelper.bold,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          GestureDetector(
                            onTap: () {
                              navigateTo(context, const SignUP());
                            },
                            child: SubTitle(
                              text: 'اشتراك',
                              size: 18,
                              color: kPrimaryColor,
                              weight: FontWeightHelper.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 200.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Action when "نسيت كلمة السر؟" is tapped
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("إجراء إعادة تعيين كلمة المرور"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          navigateTo(context, const ForgotPasswordPage());
                        },
                        child: SubTitle(
                          text: 'هل نسيت كلمة السر؟',
                          size: 18,
                          color: kPrimaryColor,
                          weight: FontWeightHelper.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
