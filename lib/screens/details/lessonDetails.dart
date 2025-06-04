import 'package:education_app/screens/Barraband%20modal/categoryModal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui'; // لإضافة التمويه
// مكتبة المؤشر الناعم
import 'package:audio_waveforms/audio_waveforms.dart'; // مكتبة موجات الصوت
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LessonDetailsScreen extends StatefulWidget {
  final Lesson lesson;
  final List<LessonVideo> lessonVideos;

  const LessonDetailsScreen({
    Key? key,
    required this.lesson,
    required this.lessonVideos,
  }) : super(key: key);

  @override
  _LessonDetailsScreenState createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  double _videoSpeed = 1.0; // السرعة الافتراضية
  late SharedPreferences _prefs;

  late AnimationController _animationController;
  bool _isVideoReady = false;
  int _currentVideoIndex = 0;
  FlutterTts flutterTts = FlutterTts();
  final PageController _pageController = PageController();
  RecorderController recorderController = RecorderController();
  String? path;
  bool isRecording = false;

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _videoSpeed =
        _prefs.getDouble('videoSpeed') ?? 1.0; // استرجاع السرعة المخزنة
  }

  void _saveVideoSpeed(double speed) {
    _prefs.setDouble('videoSpeed', speed); // حفظ السرعة في الكاش
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences().then((_) {
      _initializeVideoPlayer();
    });
    _initializeVideoPlayer();

    _initializeAudioRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeTts();
  }

  void _initializeAudioRecorder() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    recorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _initializeTts() async {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'[.,;:!?\-]'), ' ');
  }

  Future<void> _speakText(String text) async {
    String cleanedText = _cleanText(text);
    if (_isArabic(cleanedText)) {
      await flutterTts.setLanguage("ar");
    } else {
      await flutterTts.setLanguage("en-US");
    }
    await flutterTts.speak(cleanedText);
  }

  bool _isArabic(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(
        widget.lessonVideos[_currentVideoIndex].videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoReady = true;
            _animationController.forward();
            _controller
                .setPlaybackSpeed(_videoSpeed); // تعيين سرعة الفيديو المخزنة
          });
          _controller.play();
        }
      });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    flutterTts.stop();
    recorderController.dispose();
    super.dispose();
  }

  void _showRecordingPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _animationController,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AudioWaveforms(
                        recorderController: recorderController,
                        size: const Size(200.0, 100.0),
                        waveStyle: const WaveStyle(
                          waveColor: Colors.greenAccent,
                          middleLineColor: Colors.white,
                          middleLineThickness: 2.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Recording...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    _startOrStopRecording();
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        path = await recorderController.stop();
        debugPrint("Recorded file size: ${File(path!).lengthSync()}");
      } else {
        await recorderController.record(path: path);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E9), // أخضر فاتح مائل للرمادي
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(
          Icons.arrow_back,
          color: Color(0xFF80CBC4), // أخضر مائل للفيروزي        elevation: 0,
        ),
        title: Text(
          widget.lessonVideos[_currentVideoIndex].movieName,
          style: const TextStyle(
            color: Color(0xFF80CBC4), // أخضر مائل للفيروزي        elevation: 0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressBar(),
            _isVideoReady
                ? SizedBox(
                    height: 250,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: VideoPlayer(_controller)),
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            _buildVideoSpeedSlider(), // إضافة الـ Slider هنا

            _buildVideoDetails(),
            const SizedBox(height: 10),
            _buildVideoControls(),
            // const SizedBox(height: 10),
            // _buildNavigationButtons(),
            // const SizedBox(height: 20),
            _buildCustomPageIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: (_controller.value.isInitialized)
          ? _controller.value.position.inSeconds /
              _controller.value.duration.inSeconds
          : 0.0,
      backgroundColor: Colors.yellow, // لون مريح
      color: Colors.orangeAccent, // لون متباين مع خلفية هادئة
    );
  }

  Widget _buildVideoDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextWithMic(
              label: "",
              text: widget.lessonVideos[_currentVideoIndex].title,
            ),
            const SizedBox(height: 5),
            _buildTextWithMic(
              label: "",
              text: widget.lessonVideos[_currentVideoIndex].titleAr,
            ),
            const SizedBox(height: 10),
            if (widget.lessonVideos[_currentVideoIndex].details.isNotEmpty)
              _buildTextWithMic(
                label: "توضيح",
                text: widget.lessonVideos[_currentVideoIndex].details
                    .replaceAll("&ndash;", "-"),
              ),
            const SizedBox(height: 5),
            if (widget.lessonVideos[_currentVideoIndex].detailsAr.isNotEmpty)
              _buildTextWithMic(
                label: "توضيح",
                text: widget.lessonVideos[_currentVideoIndex].detailsAr
                    .replaceAll("&ndash;", "-"),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextWithMic({required String label, required String text}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "$label: $text",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        // IconButton(
        //   icon: const Icon(CupertinoIcons.speaker_3_fill),
        //   onPressed: () {
        //     _speakText(text); // نطق النص بعد تنظيفه
        //     // _showRecordingPopup(); // عرض نافذة التسجيل
        //   },
        // ),
      ],
    );
  }

  Widget _buildVideoSpeedSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          //  mainAxisAlignment: ,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "تحكم في سرعة الفيديو",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _controller.value.playbackSpeed, // سرعة الفيديو الحالية
              min: 0.5, // الحد الأدنى للسرعة
              max: 2.0, // الحد الأقصى للسرعة
              divisions: 6, // عدد الأقسام لتسهيل التحكم
              label:
                  "${_controller.value.playbackSpeed}x", // عرض السرعة الحالية
              onChanged: (double value) {
                setState(() {
                  _saveVideoSpeed(value); // حفظ السرعة في الكاش

                  _controller.setPlaybackSpeed(value); // ضبط سرعة الفيديو
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // IconButton(
          //   icon: const Icon(CupertinoIcons.gobackward_10),
          //   onPressed: () => _controller
          //       .seekTo(_controller.value.position - const Duration(seconds: 10)),
          //   // color: Color(0xFF64B5F6), // أزرق سماوي فاتح
          //   iconSize: 36,
          // ),
          _currentVideoIndex > 0
              ? _buildAnimatedContainerButton(
                  icon: Icons.skip_next_rounded,
                  color: Colors.lightBlueAccent, // لون مناسب للأطفال
                  onTap: _previousVideo,
                )
              : const SizedBox.shrink(),
          IconButton(
            icon: Icon(_controller.value.isPlaying
                ? CupertinoIcons.pause
                : CupertinoIcons.play_arrow),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            // color: Color(0xFF80CBC4), // أخضر مائل للفيروزي
            iconSize: 36,
          ),

          _isVideoReady
              ? _buildAnimatedContainerButton(
                  icon: Icons.skip_previous_rounded,
                  color: Colors.lightBlueAccent,
                  onTap: _nextVideo,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentVideoIndex > 0
                ? _buildAnimatedContainerButton(
                    icon: Icons.skip_next_rounded,
                    color: Colors.lightBlueAccent, // لون مناسب للأطفال
                    onTap: _previousVideo,
                  )
                : const SizedBox.shrink(),
            _isVideoReady
                ? _buildAnimatedContainerButton(
                    icon: Icons.skip_previous_rounded,
                    color: Colors.lightBlueAccent,
                    onTap: _nextVideo,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _nextVideo() async {
    await _initializePreferences(); // استرجاع السرعة من الكاش

    if (_currentVideoIndex < widget.lessonVideos.length - 1) {
      setState(() {
        _currentVideoIndex++;
        _isVideoReady = false;
      });
      _initializeVideoPlayer();

      _animationController.forward(from: 0);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CongratulationsScreen()),
      );
    }
  }

  void _previousVideo() async {
    await _initializePreferences(); // استرجاع السرعة من الكاش

    if (_currentVideoIndex > 0) {
      setState(() {
        _currentVideoIndex--;
        _isVideoReady = false;
        _initializeVideoPlayer();
      });
      _initializeVideoPlayer();

      _animationController.forward(from: 0);
    }
  }

  Widget _buildAnimatedContainerButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return ScaleTransition(
      scale: _animationController,
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.lessonVideos.length, (index) {
          return GestureDetector(
            onTap: () {
              // عند الضغط على النقطة، نقوم بالتبديل إلى الفيديو المحدد
              _switchToVideo(index);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentVideoIndex == index
                  ? 20
                  : 8, // تغيير العرض للنقطة النشطة
              height: 8,
              decoration: BoxDecoration(
                color: _currentVideoIndex == index
                    ? Colors.orangeAccent // لون النقطة النشطة
                    : Colors.blue[100], // لون النقطة الغير نشطة
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _switchToVideo(int index) async {
    if (index != _currentVideoIndex) {
      setState(() {
        _currentVideoIndex = index;
        _isVideoReady = false; // إعادة تعيين حالة الفيديو
      });

      // تهيئة مشغل الفيديو مباشرة دون السلايد
      _initializeVideoPlayer();
    }
  }
}

class CongratulationsScreen extends StatefulWidget {
  @override
  _CongratulationsScreenState createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with SingleTickerProviderStateMixin {
  double _buttonPosition = 0; // موقع الزر
  double _maxSlide = 300; // أقصى مقدار للسحب
  bool isFinished = false; // حالة الانتهاء
  late AnimationController _controller; // متحكم في الحركة
  late Animation<double> _animation; // حركة التدوير

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/baraband.gif',
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    // تحديث موقع الزر بناءً على السحب
                    _buttonPosition +=
                        details.delta.dx; // السحب من اليمين لليسار
                    // التأكد من عدم تجاوز الحدود
                    if (_buttonPosition > _maxSlide) {
                      _buttonPosition = _maxSlide;
                    } else if (_buttonPosition < 0) {
                      _buttonPosition = 0;
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (_buttonPosition <= _maxSlide) {
                    // إذا تم سحب الزر بالكامل
                    setState(() {
                      isFinished = true; // تعيين حالة الانتهاء
                      _controller.forward(); // بدء التدوير
                      // الانتقال إلى الدرس التالي بعد فترة زمنية
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pop(
                            context); // استبدل هذا برمز الانتقال للدرس التالي
                      });
                    });
                  } else {
                    // إذا لم يتم سحب الزر بالكامل، إعادة الزر لموقعه الأصلي
                    setState(() {
                      _buttonPosition = 0;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // الزر الأساسي
                      Positioned(
                        right: _buttonPosition, // بدء الزر من اليمين
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animation.value * 2 * 3.14,
                              child: Opacity(
                                opacity:
                                    isFinished ? (1 - _animation.value) : 1,
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // نص الزر
                      Center(
                        child: Text(
                          'الدرس التالي',
                          style: const TextStyle(
                              fontSize: 25, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isFinished) // إذا كانت الحالة انتهت
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: 0, // جعلها شفافة
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
