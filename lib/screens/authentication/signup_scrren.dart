import 'package:education_app/constants/color.dart';
import 'package:education_app/constants/font_weight_helper.dart';
import 'package:education_app/constants/size.dart';
import 'package:education_app/constants/sub_title.dart';
import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';
import 'package:education_app/screens/authentication/login_screen.dart';
import 'package:education_app/screens/authentication/widgets/app_text_form_field.dart';
import 'package:education_app/screens/navbar/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUP extends StatefulWidget {
  const SignUP({Key? key}) : super(key: key);

  @override
  State<SignUP> createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/icons/ui2.png',
              fit: BoxFit.cover,
              height: 920.h,
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
                      controller: nameController,
                      hintText: 'اسم المستخدم',
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    AppTextFormField(
                      controller: emailController,
                      hintText: 'البريد الاكتروني',
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    AppTextFormField(
                      controller: passwordController,
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
                    AppTextFormField(
                      controller: phoneController,
                      hintText: 'رقم الهاتف',
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    AppTextFormField(
                      controller: countryController,
                      hintText: 'البلد',
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    // إضافة الأيقونات لتسجيل الدخول عبر فيسبوك وجوجل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة فيسبوك
                        GestureDetector(
                          onTap: () {
                            BlocProvider.of<AuthCubit>(context)
                                .signupWithFacebook();
                          },
                          child: Image.asset(
                            'assets/icons/facebookpng.png',
                            width: 40.w,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        // أيقونة جوجل
                        GestureDetector(
                          onTap: () {
                            // BlocProvider.of<AuthCubit>(context)
                            //     .signupWithGoogle();
                          },
                          child: Image.asset(
                            'assets/icons/google.png',
                            width: 40.w,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SubTitle(
                          text: 'هل لديك حساب?',
                          size: 18,
                          color: darkBlue,
                          weight: FontWeightHelper.bold,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            navigateAndFinish(context, const LogIn());
                          },
                          child: SubTitle(
                            text: 'دخول',
                            size: 18,
                            color: kPrimaryColor,
                            weight: FontWeightHelper.medium,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccessState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم التسجيل بنجاح!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          navigateAndFinish(context, const MyNavbarBottm());
                        } else if (state is AuthFailureState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('خطأ: ${state.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoadingState) {
                          return CircularProgressIndicator();
                        }
                        return GestureDetector(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              BlocProvider.of<AuthCubit>(context).signup(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                passwordConfirmation:
                                    passwordController.text.trim(),
                                phone: phoneController.text.trim(),
                                name: nameController.text.trim(),
                                country: countryController.text.trim(),
                              );
                            }
                          },
                          child: Container(
                            width: 200.w,
                            height: 55.h,
                            alignment: Alignment.centerRight,
                            decoration: const BoxDecoration(
                              color: kPrimaryLight,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: SubTitle(
                                text: 'تسجيل',
                                size: 30,
                                color: uiColorwhite,
                                weight: FontWeightHelper.medium,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
