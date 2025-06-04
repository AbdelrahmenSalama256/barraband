import 'package:education_app/screens/authentication/ChangePasswordPage.dart';
import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:education_app/screens/authentication/widgets/app_text_form_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعادة تعيين كلمة المرور'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // الانتقال إلى صفحة تغيير كلمة المرور
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordPage()),
            );
          }

          if (state is AuthSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'نجاح العملية'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // العودة للصفحة السابقة بعد النجاح
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextFormField(
                  controller: emailController,
                  hintText: 'البريد الإلكتروني',
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    debugPrint('Button pressed'); // طباعة عند الضغط على الزر
                    if (formKey.currentState!.validate()) {
                      debugPrint('Form is valid, calling forgotPassword');
                      BlocProvider.of<AuthCubit>(context).forgotPassword(
                        email: emailController.text.trim(),
                      );
                    } else {
                      debugPrint('Form is invalid');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'إرسال رابط إعادة تعيين كلمة المرور',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
