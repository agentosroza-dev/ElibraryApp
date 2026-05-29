import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../config/theme.dart';

class CategoryBooksLoadingState extends StatelessWidget {
  const CategoryBooksLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: 7,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, index) {
                  final labels = ['All', 'Fiction', 'Science', 'History', 'Technology', 'Art', 'Poetry'];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.iosGray6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labels[index],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: AppColors.iosGray6,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Book Title Here'),
                              SizedBox(height: 2),
                              Text('Author Name'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
