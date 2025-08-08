import 'package:flutter/material.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/message_model.dart';
import 'package:sample_app/presentation/widgets/chat_history_space.dart';
import 'package:sample_app/services/nearby_services.dart';

class ChatPage extends StatelessWidget {
  final ChatUserModel user;
  final service = NearbyServices();

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  ChatPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.userName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ChatHistorySpace(user: user),
              ),

              const Spacer(),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Send Message",
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          service.sendChatMessage(
                            MessageModel(
                              value: _controller.text,
                              createdTime: DateTime.now(),
                            ),
                            user,
                          );
                        }
                      },
                      icon: Icon(Icons.send),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "message shouldn't be empty";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
