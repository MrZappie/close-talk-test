
import 'package:flutter/material.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/presentation/chat_page.dart';

class ChatUserTile extends StatelessWidget {
  final ChatUserModel user;

  const ChatUserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: BoxBorder.all(color: Colors.greenAccent),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ChatPage(user: user)));
        },
        leading: CircleAvatar(backgroundColor: Colors.blue, radius: 40),
        title: Text(user.userName, style: TextStyle(fontSize: 45)),
        subtitle: Text(user.id),
        trailing: Text(user.id),
      ),
    );
  }
}
