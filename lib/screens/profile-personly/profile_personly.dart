import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';
import 'package:education_app/screens/profile-personly/cubit/profile_cubit.dart';
import 'package:education_app/screens/profile-personly/modal/profile_Modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // استخدام BLoC
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/color.dart';
import '../../constants/font_weight_helper.dart';
import '../../constants/size.dart';
import '../../constants/sub_title.dart';
import '../navbar/nav_bar.dart';

class ProfilePersonly extends StatefulWidget {
  const ProfilePersonly({Key? key}) : super(key: key);

  @override
  _ProfilePersonlyState createState() => _ProfilePersonlyState();
}

class _ProfilePersonlyState extends State<ProfilePersonly> {
  List<String> _tasks = [];
  bool _isLoadingTasks = false;
  TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    // استدعاء تحميل الرتب عبر ProfileCubit
    context.read<ProfileCubit>().fetchRanks();
    context.read<ProfileCubit>().fetchRanks();
    context.read<AuthCubit>().fetchUserDetails(); // استدعاء بيانات البروفايل
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoadingTasks = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? [];
      _isLoadingTasks = false;
    });
  }

  Future<void> _addTask(String task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoadingTasks = true;
      _tasks.add(task);
      prefs.setStringList('tasks', _tasks);
      _isLoadingTasks = false;
    });
  }

  Future<void> _removeTask(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.removeAt(index);
      prefs.setStringList('tasks', _tasks);
    });
  }

// إضافة ويدجت لعرض تفاصيل البروفايل
  Widget _buildProfileDetails() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccessState) {
          var profile =
              state.user; // نفترض أن بيانات البروفايل تأتي في هذا الـ state
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileRow(
                    "اسم المستخدم:", profile!.info!.name ?? "غير متوفر"),
                _buildProfileRow(
                    "البريد الإلكتروني:", profile.info!.email ?? "غير متوفر"),
                _buildProfileRow(
                    "رقم الهاتف:", profile.info!.phone ?? "غير متوفر"),
              ],
            ),
          );
        } else if (state is AuthLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Text("فشل في جلب بيانات البروفايل"));
        }
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xfffbdb4c), // لون الخلفية
          borderRadius: BorderRadius.circular(10), // الحدود المستديرة
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label, // النص الوصفي (label)
              style: TextStyle(
                fontSize: 16.sp,
                color: darkBlue, // اللون المماثل في النصوص
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                value, // قيمة البيانات (value)
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black, // اللون الافتراضي للقيمة
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(String task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "تفاصيل المهمة",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                task,
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إغلاق"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(hintText: "أدخل اسم المهمة"),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (_taskController.text.isNotEmpty) {
                    _addTask(_taskController.text);
                    _taskController.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("إضافة"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is RanksLoadingState) {
              return Center(
                  child: CircularProgressIndicator()); // عرض حالة التحميل
            } else if (state is RanksSuccessState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildRanksAndTasksList(
                        state.ranks), // عرض الرتب والمهام معًا
                  ],
                ),
              );
            } else if (state is RanksFailureState) {
              return Center(
                  child: Text("فشل في تحميل الرتب: ${state.message}"));
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildRanksAndTasksList(List<Rank> ranks) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                    )),
                SizedBox(
                  width: 100.sp,
                ),
                Align(
                  alignment: Alignment.center,
                  child: SubTitle(
                    text: 'بيانات الطالب',
                    size: 25,
                    color: Colors.white,
                    weight: FontWeightHelper.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildProfileDetails(), // إضافة تفاصيل البروفايل هنا

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SubTitle(
                text: 'مستواك التعليمي',
                size: 18,
                color: Colors.white,
                weight: FontWeightHelper.bold,
              ),
            ),
          ),
          // قائمة الرتب
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: ranks.length,
            itemBuilder: (context, index) {
              var rank = ranks[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _showRankDetails(rank);
                    }
                  },
                  child: Container(
                    height: 60.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: _getColorForRank(index),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: _getCircleColorForRank(index),
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SubTitle(
                          text: rank.nameAr, // عرض الاسم باللغة العربية
                          size: 16,
                          color: Colors.white,
                          weight: FontWeightHelper.bold,
                        ),
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(
              color: Colors.white,
              thickness: 1.0,
              height: 0.5,
            ),
          ),
          SizedBox(height: 10.h),
          // عرض المهام
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SubTitle(
                    text: 'اضف مهامك',
                    size: 20,
                    color: darkBlue,
                    weight: FontWeightHelper.bold),
                GestureDetector(
                  onTap: () => _showAddTaskDialog(),
                  child: ElevatedButton.icon(
                    onPressed: _showAddTaskDialog,
                    icon: Icon(Icons.add),
                    label: Text('إضافة مهمة جديدة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryLight,
                      // onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // قائمة المهام
          SizedBox(
            height: 300.h, // تحديد ارتفاع مناسب لقائمة المهام
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_tasks[index]),
                  onDismissed: (direction) {
                    _removeTask(index);
                  },
                  background: Container(
                    color: Colors.redAccent.shade100,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.w),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20),
                    child: GestureDetector(
                      onTap: () => _showTaskDetails(_tasks[index]),
                      child: Container(
                        height: 60.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: _getTaskColor(index),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: _getTaskColor(index),
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SubTitle(
                              text: _tasks[index],
                              size: 16,
                              color: Colors.white,
                              weight: FontWeightHelper.bold,
                            ),
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRankDetails(Rank rank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    "تفاصيل الرتبة",
                    style:
                        TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "رتبتك: ${rank.nameAr}",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  Text(
                    "عدد الفيديوهات: ${rank.videosCount}",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  Text(
                    "النقاط المطلوبة: ${rank.min}",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("إغلاق"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getTaskColor(int index) {
    return index % 2 == 0 ? Colors.blue.shade100 : Colors.orange.shade100;
  }

  Color _getColorForRank(int index) {
    switch (index % 3) {
      case 0:
        return Colors.blue.shade100;
      case 1:
        return Colors.orange.shade100;
      case 2:
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getCircleColorForRank(int index) {
    switch (index % 3) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
