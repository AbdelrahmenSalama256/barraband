import 'package:education_app/screens/Barraband%20modal/categoryModal.dart';
import 'package:education_app/screens/details/lessonDetails.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatefulWidget {
  final Lesson lesson; // تمرير الدرس بشكل صحيح
  const LessonCard({Key? key, required this.lesson}) : super(key: key);

  @override
  _LessonCardState createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation, // أنيميشن التحرك من اليمين إلى اليسار
      child: GestureDetector(
        onTap: () {
          if (widget.lesson.lessonVideos.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonDetailsScreen(
                  lesson: widget.lesson,
                  lessonVideos: widget.lesson.lessonVideos, // تمرير الفيديوهات
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No videos available for this lesson.'),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // إضافة الحواف الدائرية
            color: Colors.grey[300], // تغيير اللون إلى الرمادي الفاتح
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصورة في الأعلى
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: widget.lesson.photo.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Image.network(
                          widget.lesson.photo,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 50);
                          },
                        ),
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 150,
                        color: Colors.grey), // Default icon if no image
              ),
              // النص في الأسفل
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ), // إضافة الحواف الدائرية للنص
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.lesson.details.replaceAll("&ndash;", "-"),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70, // لون النص التفصيلي
                          ),
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
