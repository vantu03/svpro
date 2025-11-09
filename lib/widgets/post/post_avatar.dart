import 'package:flutter/material.dart';

class PostAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final double size;

  const PostAvatar({
    super.key,
    this.url,
    this.radius = 20,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: (url != null && url!.isNotEmpty) ? NetworkImage(url!) : null,
      child: (url == null || url!.isEmpty)
          ? Icon(Icons.person, size: size, color: Colors.white)
          : null,
    );
  }
}
