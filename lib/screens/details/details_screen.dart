import 'package:education_app/constants/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/lesson_card.dart';
import 'package:education_app/screens/home/cubit/main_cubit.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final String img;
  final int categoryId;
  final String lessson;

  const DetailsScreen({
    Key? key,
    required this.title,
    required this.img,
    required this.categoryId,
    required this.lessson,
  }) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void initState() {
    super.initState();
    print('Received category ID: ${widget.categoryId}');
    BlocProvider.of<MainCubit>(context).fetchLessons(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 15),
                _buildLessonsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // توزيع العناصر على الجانبين
        children: [
          // زر الرجوع
          Container(
            width: 30,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xfffbdb4c),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            ),
          ),
          // اسم القسم الفرعي والصورة
          Expanded(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // وضع المحتوى على اليمين
              children: [
                // اسم القسم الفرعي
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(width: 10), // مساحة بين النص والصورة
                // صورة القسم الفرعي مع استخدام Hero
                Hero(
                  tag:
                      'subCategory-${widget.categoryId}', // استخدام Hero tag مشترك
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10), // جعل الصورة بحواف دائرية
                    child: Image.network(
                      "${widget.img}", // رابط الصورة (استبدله برابط الصورة الحقيقية)
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error,
                            size: 50); // في حال وجود خطأ في تحميل الصورة
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList() {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state is LessonsLoadingState) {
          return SizedBox(
              child: Column(
            children: [
              const Center(child: CircularProgressIndicator()),
            ],
          ));
        } else if (state is LessonsLoadedState) {
          return Expanded(
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              itemCount: state.lessons.length,
              itemBuilder: (_, index) {
                final lesson = state.lessons[index];
                return LessonCard(lesson: lesson);
              },
            ),
          );
        } else if (state is LessonsFailureState) {
          return Center(
            child: Text('فشل في تحميل الدروس: ${state.message}'),
          );
        } else {
          return const Center(child: Text('لا توجد دروس متاحة.'));
        }
      },
    );
  }
}

class CustomTabView extends StatefulWidget {
  final Function(int) changeTab;
  final int index;

  const CustomTabView({Key? key, required this.changeTab, required this.index})
      : super(key: key);

  @override
  State<CustomTabView> createState() => _CustomTabViewState();
}

class _CustomTabViewState extends State<CustomTabView> {
  final List<String> _tags = ["Playlist (22)", "Description"];

  Widget _buildTags(int index) {
    return GestureDetector(
      onTap: () => widget.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .08, vertical: 15),
        decoration: BoxDecoration(
          color: widget.index == index ? kPrimaryColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _tags[index],
          style: TextStyle(
            color: widget.index != index ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: _tags
            .asMap()
            .entries
            .map((MapEntry map) => _buildTags(map.key))
            .toList(),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final Color? color;
  final VoidCallback onTap;

  const CustomIconButton({
    Key? key,
    required this.child,
    required this.height,
    required this.width,
    this.color = const Color(0xfffbdb4c),
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Center(child: child),
        onTap: onTap,
      ),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 2.0,
            spreadRadius: .05,
          ),
        ],
      ),
    );
  }
}
