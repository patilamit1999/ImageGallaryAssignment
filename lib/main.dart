import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:awss3/model/image_model.dart';
import 'package:awss3/services/auth_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'HomeScreen/HomeScreen.dart';
import 'HomeScreen/ListPreview.dart';
import 'amplifyconfiguration.dart';
import 'login/login_screen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication SQLite',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginScreen(),
    );
  }
}

Future<void> _configureAmplify() async {
  try {

    await Amplify.addPlugin(AmplifyStorageS3());
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class FilePickingApp extends StatelessWidget {
  const FilePickingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: Authenticator.builder(),
        home: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('File Picking'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const ListPreviousFilesView();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt),
                ),
                IconButton(
                  onPressed: () {
                    Amplify.Auth.signOut();
                  },
                  icon: const Icon(Icons.exit_to_app),
                ),
              ],
            ),
            body: const HomeScreen(),
          );
        }),
      ),
    );
  }
}
