import 'package:education_app/constants/font_weight_helper.dart';
import 'package:education_app/constants/sub_title.dart';
import 'package:education_app/screens/Barraband%20modal/categoryModal.dart';
import 'package:education_app/screens/details/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CourseScreen extends StatefulWidget {
  final int categoryId;
  final List<SubCategory>? subCategories;

  const CourseScreen({
    Key? key,
    required this.categoryId,
    required this.subCategories,
  }) : super(key: key);

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Stack(
                    children: [
                      Align(
                        child: SubTitle(
                          text: 'الأقسام الفرعية',
                          size: 25,
                          color: const Color(0xff4CAF50),
                          weight: FontWeightHelper.semiBold,
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xff4CAF50), // لون الزر
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: widget.subCategories != null &&
                          widget.subCategories!.isNotEmpty
                      ? ListView.builder(
                          itemCount: widget.subCategories!.length,
                          itemBuilder: (context, index) {
                            // تطبيق أنيميشن التحميل بالتناوب
                            final bool isEven = index % 2 == 0;
                            final offset = isEven
                                ? const Offset(1, 0)
                                : const Offset(-1, 0);

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: offset,
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: SubCategoryCard(
                                subCategory: widget.subCategories![index],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "لا توجد أقسام فرعية متاحة",
                            style: TextStyle(color: Colors.grey, fontSize: 18),
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

class SubCategoryCard extends StatefulWidget {
  final SubCategory subCategory;

  const SubCategoryCard({
    Key? key,
    required this.subCategory,
  }) : super(key: key);

  @override
  _SubCategoryCardState createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<SubCategoryCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped; // لتفعيل الانيميشن عند الضغط
        });

        // الانتقال إلى شاشة التفاصيل مع تمرير الصورة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              img: widget.subCategory.photo!,
              lessson: widget.subCategory.detailsAr!,
              categoryId: widget.subCategory.id,
              title: widget.subCategory.nameAr ?? 'No Title',
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isTapped
              ? const Color(0xff388E3C) // لون أخضر أغمق عند الضغط
              : const Color(0xff4CAF50), // لون أخضر أهدأ
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصورة في الأعلى مع Hero animation
            Hero(
              tag: 'subCategory-${widget.subCategory.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: widget.subCategory.photo?.isNotEmpty == true
                    ? Image.network(
                        widget.subCategory.photo!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error); // في حال وجود خطأ
                        },
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 150, color: Colors.grey), // Default icon
              ),
            ),
            // النص في الأسفل
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                widget.subCategory.nameAr ?? 'No Name', // النص
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  color: Colors.white, // لون النص
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
