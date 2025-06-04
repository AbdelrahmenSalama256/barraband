import 'package:education_app/constants/size.dart';
import 'package:education_app/screens/Barraband%20modal/categoryModal.dart';
import 'package:education_app/screens/authentication/cubit/auth_cubit.dart';
import 'package:education_app/screens/home/cubit/main_cubit.dart';
import 'package:education_app/screens/course/course_screen.dart';
import 'package:education_app/screens/navbar/settings/settings_scrren.dart';
import 'package:education_app/widgets/cardView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturedScreen extends StatefulWidget {
  const FeaturedScreen({Key? key}) : super(key: key);

  @override
  _FeaturedScreenState createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  @override
  void initState() {
    super.didChangeDependencies();
    // Fetch user details and categories when the screen initializes
    BlocProvider.of<AuthCubit>(context).fetchUserDetails();
    BlocProvider.of<MainCubit>(context).fetchCategories();
  }

  // Function to handle category click
  void onCategoryClick(BuildContext context, Category category) {
    BlocProvider.of<MainCubit>(context).fetchSubCategories(category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthFailureState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AuthLoadingState) {
                          return const CircularProgressIndicator();
                        } else if (state is AuthSuccessState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "مرحبًا ${state.user!.info?.name ?? 'مستخدم'},",
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "ابحث عن دورة تريد تعلمها",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Text("فشل في تحميل بيانات المستخدم");
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        // انتقل إلى صفحة البروفايل
                        navigateTo(context, Profile());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: Offset(5, 5), // Position of the shadow
                            ),
                            BoxShadow(
                              color: Colors.white, // Highlight effect
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(-5, -5), // Highlight position
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/images/1_Ld1KM2WSfJ9YQ4oeRf7q4Q.png",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'ابحث عن أي شيء',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "الفئات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle "عرض الكل" (See All) click
                    //   },
                    //   child: const Text(
                    //     "عرض الكل",
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Colors.purple,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<MainCubit, MainState>(
                  builder: (context, state) {
                    if (state is CategoriesLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoriesLoadedState) {
                      final List<Category> categories =
                          state.categories.cast<Category>();

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryCard(
                            name: category.nameAr,
                            image: category.photo,
                            onTap: () async {
                              // Handle click
                              onCategoryClick(context, category);
                              // بعد العودة من الشاشة الفرعية، إعادة تحميل البيانات
                              setState(() {
                                BlocProvider.of<MainCubit>(context)
                                    .fetchCategories();
                              });
                            },
                          );
                        },
                      );
                    } else if (state is CategoriesFailureState) {
                      return Center(
                        child:
                            Text('Failed to load categories: ${state.message}'),
                      );
                    } else {
                      return const Text('No categories available');
                    }
                  },
                ),
              ),
              BlocListener<MainCubit, MainState>(
                listener: (context, state) {
                  if (state is SubCategoriesLoadedState) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseScreen(
                          categoryId: state.categoryId,
                          subCategories: state.subCategories,
                        ),
                      ),
                    ).then((_) {
                      // إعادة تحميل الفئات عند الرجوع من الصفحة الفرعية
                      BlocProvider.of<MainCubit>(context).fetchCategories();
                    });
                  } else if (state is SubCategoriesFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
