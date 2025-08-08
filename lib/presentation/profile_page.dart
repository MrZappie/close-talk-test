import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/models/user_profile.dart';
import 'package:sample_app/services/nearby_services.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key}) {
    final Box<UserProfile> profileBox = Hive.box<UserProfile>(kBoxProfile);
    final me = profileBox.get('me');
    _controller.text = me?.userName ?? '';
  }

  final _service = NearbyServices();
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Profile")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("User name: ", style: TextStyle(fontSize: 45)),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Don't be Empty";
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _service.updateUserName(_controller.text);
                  }
                },
                child: Text("Edit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
