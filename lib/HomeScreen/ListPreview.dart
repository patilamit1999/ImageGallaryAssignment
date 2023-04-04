
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/image_model.dart';
import '../services/auth_services.dart';

class ListPreviousFilesView extends StatefulWidget {
  const ListPreviousFilesView({Key? key}) : super(key: key);

  @override
  State<ListPreviousFilesView> createState() => _ListPreviousFilesViewState();
}

class _ListPreviousFilesViewState extends State<ListPreviousFilesView> {
  List<ImageData> items = [];
  DBHelper? dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadImagesFromLocalDB();
  }

  Future<void> _loadImagesFromLocalDB() async {
    final images = await dbHelper!.getAllImages();
    setState(() {
      items = images;
    });
  }

  void _deleteImage(int id) async {
    await dbHelper!.deleteImage(id);
    await _loadImagesFromLocalDB();
  }


  Future<void> listAlbum() async {
    try {
      //final result = await Amplify.Storage.list().result;
      final result = await dbHelper!.getAllImages();
      items
        ..clear()
        ..addAll(result);

      safePrint('Listed items: ${result}');
    } on StorageException catch (e) {
      safePrint(e.message);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Uploads')),
      body: FutureBuilder<void>(
        future: listAlbum(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                /*CachedNetworkImage(
                  imageUrl: 'https://awss30cd5f10de5064370b9a186c44827986c181928-test.s3.ap-south-1.amazonaws.com/public/${item}',
                )*/
                return ListTile(
                  title: Text(item.title),
                  onTap: () {
                    // Create a NetworkImage widget with the item key
                    // final networkImage = NetworkImage(
                    //   'https://awss30cd5f10de5064370b9a186c44827986c181928-test.s3.ap-south-1.amazonaws.com/public/${item.key}',
                    // );

                    // Display the image using the Image widget
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(
                            content: Image.file(File(item.path)),
                          ),
                    );
                  },
                  //leading: Image.network('https://awss30cd5f10de5064370b9a186c44827986c181928-test.s3.ap-south-1.amazonaws.com/public/${item.title}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text('Are you sure you want to delete ${item.title}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        //await deleteImage(item);
                        _deleteImage(item.id!);
                      }
                    },
                  ),
                );
              },
            );
          }
        }),
      ),
    );

  }

  Future<void> deleteImage(StorageItem item) async {
    try {
      await Amplify.Storage.remove(key: item.key);
      setState(() {
        items.remove(item);
      });
      safePrint('Deleted item: ${item.key}');
    } on StorageException catch (e) {
      safePrint(e.message);
    }
  }

}