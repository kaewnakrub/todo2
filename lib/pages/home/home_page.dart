import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo2/const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Todo'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              firebaseAuth.signOut();
            },
          )
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: firestore
              .collection('todos')
              .doc(firebaseAuth.currentUser!.uid)
              .collection('items')
              .orderBy('title', descending: false)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // has error..
            if (snapshot.hasError) {
              return Text('Error');
            }

            // loading..
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading..');
            }

            // show data
            var docs = snapshot.data!.docs;
            log(docs.length.toString());

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (BuildContext context, int index) {
                String ttitle = docs[index]['title'];
                bool complete = docs[index]['complete'];
                log(' $ttitle complete: $complete');

                return CheckboxListTile(
                  title: Text(ttitle,
                      style: TextStyle(
                          decoration: (complete)
                              ? TextDecoration.lineThrough
                              : TextDecoration.none)),
                  value: complete,
                  onChanged: (value) {
                    // update data to firestore
                    log('click $ttitle complete: $value');
                    firestore
                        .collection('todos')
                        .doc(firebaseAuth.currentUser!.uid)
                        .collection('items')
                        .doc(docs[index].id)
                        .update({
                      'complete': value,
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // show dialog..
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: TextFormField(
                    controller: textEditingController,
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        // save data to firestore..
                        if (textEditingController.text.trim().isNotEmpty) {
                          firestore
                              .collection('todos')
                              .doc(firebaseAuth.currentUser!.uid)
                              .collection('items')
                              .add({
                            'title': textEditingController.text.trim(),
                            'complete': false,
                          }).whenComplete(() => Navigator.pop(context));
                        }
                      },
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}
