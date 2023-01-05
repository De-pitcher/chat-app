import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, messageSnaphot) {
        if (messageSnaphot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!messageSnaphot.hasData) {
          return const Text('No Data Currently');
        }
        final chatDoc = messageSnaphot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: chatDoc.length,
          itemBuilder: (ctx, index) => Text(chatDoc[index]['text']),
        );
      },
    );
  }
}