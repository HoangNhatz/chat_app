import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessenges extends StatelessWidget {
  const ChatMessenges({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').orderBy('createdAt', descending: true).snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        final loadMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessenge = loadMessages[index].data();
            final nextMessage = index + 1 < loadMessages.length ? loadMessages[index+1].data() : null;
            final currentMessageUserId = chatMessenge['userId'];
            final nextMessageUserId = nextMessage != null ? nextMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;
            if(nextUserIsSame) {
              return MessageBubble.next(message: chatMessenge['text'], isMe: authenticatedUser.uid == currentMessageUserId);
            } else {
              return MessageBubble.first(userImage: chatMessenge['userImage'], username: chatMessenge['username'], message: chatMessenge['text'], isMe: authenticatedUser.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
