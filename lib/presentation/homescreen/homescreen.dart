import 'dart:developer';
import 'dart:io';

import 'package:face_validator/presentation/register/face_capture_page.dart';
import 'package:face_validator/services/auth/auth_service.dart';
import 'package:face_validator/services/storage/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  Future<void> _validate(BuildContext context) async {
    try{
      final image = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const FaceCapturePage()),
    );

    if(image == null ) log('zzrr image null');

    if (image == null) return;

    final auth = AuthService();

    final result = await auth.validateUser(image);

    log('zzrr test: $result');
      

    Fluttertoast.showToast(msg: result ? "TRUE" : "FALSE");
    }catch(e){
      print('Error: $e');
    }
  }
  final hive = HiveService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: ()  => hive.clearUsers(), icon: Icon(Icons.abc))],),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _validate(context),
          child: Text('Validate'),
        ),
      ),
    );
  }
}
