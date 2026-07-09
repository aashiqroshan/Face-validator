import 'package:face_validator/presentation/login/login_page.dart';
import 'package:face_validator/presentation/register/bloc/register_bloc.dart';
import 'package:face_validator/repositories/face_repository_impl.dart';
import 'package:face_validator/services/auth/auth_service.dart';
import 'package:face_validator/services/storage/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  final hiveService = HiveService();
  final repository = FaceRepositoryImpl(hiveService);
  final authService = AuthService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => RegisterBloc(),)],
      child: MaterialApp(home: LoginPage()),
    );
  }
}
