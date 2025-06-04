import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تغيير كلمة المرور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور الجديدة';
                  }
                  return null; // إذا كانت المدخلات صحيحة
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى تأكيد كلمة المرور';
                  } else if (value != newPasswordController.text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null; // إذا كانت المدخلات صحيحة
                },
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    // تنفيذ عملية تغيير كلمة المرور
                    BlocProvider.of<AuthCubit>(context).changePassword(
                      newPassword: newPasswordController.text.trim(),
                    );
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
                      'تغيير كلمة المرور',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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
