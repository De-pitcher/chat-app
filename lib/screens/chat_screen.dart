import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats/YYoazchoKpJsoNc3Plm2/messages')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            final document = snapshot.data!.docs;
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, i) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(document[i]['text']),
                );
              },
            );
          }
          return const Text('No Data');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseFirestore.instance
              .collection('chats/YYoazchoKpJsoNc3Plm2/messages')
              .add({'text': 'This text was added by clicking the button'});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
