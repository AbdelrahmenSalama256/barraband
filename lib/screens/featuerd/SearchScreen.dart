import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/screens/Barraband%20modal/categoryModal.dart';
import 'package:education_app/screens/home/cubit/main_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // تحديث نص البحث
                });
              },
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
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<MainCubit, MainState>(
                builder: (context, state) {
                  if (state is CategoriesLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CategoriesLoadedState) {
                    final List<Category> categories =
                        state.categories.cast<Category>();
                    final filteredCategories = _searchQuery.isEmpty
                        ? categories
                        : categories.where((category) {
                            return category.nameAr.contains(_searchQuery);
                          }).toList();

                    return ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return ListTile(
                          title: Text(category.nameAr),
                          onTap: () {
                            // الانتقال إلى صفحة الدروس أو التفاصيل
                          },
                        );
                      },
                    );
                  } else if (state is CategoriesFailureState) {
                    return Center(
                        child: Text('فشل في تحميل الفئات: ${state.message}'));
                  } else {
                    return const Text('لا توجد فئات متاحة');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
