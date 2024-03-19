// ignore_for_file: unnecessary_type_check

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileSkeletonLoadingIndicator extends StatelessWidget {
  const ProfileSkeletonLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[200]!,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: CircleAvatar(
              radius: 75,
              backgroundColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonContainer(double.infinity),
                const SizedBox(height: 10),
                _buildSkeletonContainer(200),
                const SizedBox(height: 10),
                _buildSkeletonContainer(double.infinity),
                const SizedBox(height: 10),
                _buildSkeletonContainer(double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonContainer(double width) {
    return Container(
      height: 20,
      width: width is double ? width : null,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
