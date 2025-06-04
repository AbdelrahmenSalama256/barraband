import 'package:education_app/constants/size.dart';
import 'package:education_app/screens/profile-personly/modal/profile_Modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../constants/font_weight_helper.dart';
import '../../../constants/sub_title.dart';
import '../../navbar/nav_bar.dart';
import '../../profile-personly/cubit/profile_cubit.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  String? _selectedPackageTitle; // لتحديد الباقة باستخدام العنوان

  @override
  void initState() {
    super.initState();
    // جلب بيانات الحزم والاشتراكات عند بناء الصفحة
    context.read<ProfileCubit>().fetchPackages();
    context.read<ProfileCubit>().fetchUserSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xfffbdb4c),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            navigateAndFinish(context, const MyNavbarBottm()),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 120.sp),
                    Expanded(
                      child: Center(
                        child: SubTitle(
                          text: 'الاشتراكات',
                          size: 30,
                          color: Colors.white,
                          weight: FontWeightHelper.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // عرض حالة الاشتراك منفصل عن الـ packages
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is UserSubscriptionsLoadingState) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'جاري تحميل بيانات الاشتراك...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else if (state is UserSubscriptionsEmptyState) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'أنت غير مشترك في أي باقة.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else if (state is UserSubscriptionsSuccessState) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'أنت مشترك في ${state.subscriptions.length} باقة.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else if (state is UserSubscriptionsFailureState) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'حدث خطأ أثناء جلب بيانات الاشتراك.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 20.h),

              // BlocBuilder لاستقبال حالة الحزم وعرض البيانات
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  if (state is PackagesLoadingState) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is PackagesSuccessState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: state.packages.map((package) {
                          bool isSelected = _selectedPackageTitle ==
                              package.title; // مقارنة العنوان
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPackageTitle = package
                                      .title; // تحديد الباقة باستخدام العنوان
                                });
                              },
                              child: PackageCard(
                                title: package.title,
                                price: package.price,
                                currency: package.currency,
                                days: package.days,
                                allowedLessons: package.allowedLessons,
                                discount: getDiscountText(package),
                                isSelected: isSelected,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else if (state is PackagesFailureState) {
                    return Center(child: Text(state.message));
                  }
                  return Container();
                },
              ),

              SizedBox(height: 20.h),
              // عرض تفاصيل الباقة المحددة
              if (_selectedPackageTitle != null) ...[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الباقة المختارة:',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // عرض العنوان الذي تم تحديده
                        Text(
                          'اسم الباقة: $_selectedPackageTitle',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SubTitle(
                  text: 'متى سيتم الفوترة؟',
                  size: 20,
                  color: Colors.white,
                  weight: FontWeightHelper.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SubTitle(
                  text:
                      'سيتم فوترة حسابك في نهاية فترة التجربة أو عند تأكيد الاشتراك.',
                  size: 16,
                  color: Colors.white70,
                  weight: FontWeightHelper.regular,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لحساب النص الخاص بالتخفيض إذا وجد
  String getDiscountText(Package package) {
    if (package.days >= 365) {
      return 'وفر 66%';
    } else if (package.days >= 90) {
      return 'وفر 33%';
    }
    return ''; // بدون خصم
  }
}

class PackageCard extends StatelessWidget {
  final String title;
  final double price;
  final String currency;
  final int days;
  final int allowedLessons;
  final String discount;
  final bool isSelected;

  const PackageCard({
    Key? key,
    required this.title,
    required this.price,
    required this.currency,
    required this.days,
    required this.allowedLessons,
    required this.discount,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected
              ? Colors.blue
              : (discount.isNotEmpty ? Colors.orange : Colors.grey),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (discount.isNotEmpty)
            Text(
              discount,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: 10.h),
          Text(
            'الباقة: $title',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'السعر: $price $currency',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'المدة: ${days ~/ 30} شهر',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'الدروس المسموح بها: $allowedLessons',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
