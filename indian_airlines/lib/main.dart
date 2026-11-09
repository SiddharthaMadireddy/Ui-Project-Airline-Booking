import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const IndianAirlinesApp());
}
