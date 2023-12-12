import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/model/category.dart';
import 'package:shopping_list/model/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final formkey = GlobalKey<FormState>();

  var enteredname = '';
  var enteredquantity = 1;
  var selectedcategory = categories[Categories.vegetables]!;
  var issending = false;
  void save() async {
    formkey.currentState!.validate();
    formkey.currentState!.save();
    setState(() {
      issending = true;
    });
    final url = Uri.https(
        //project url
        'flutter-prep-eab00-default-rtdb.firebaseio.com',
        'shopping-list.json');
    //post request
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': enteredname,
          'quantity': enteredquantity,
          'category': selectedcategory.title,
        }));

    final Map<String, dynamic> responsedata = json.decode(response.body);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(GroceryItem(
        id: responsedata['name'],
        name: enteredname,
        quantity: enteredquantity,
        category: selectedcategory));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Item',
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 30),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Enter valid name';
                    }
                    return null;
                  },
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  onSaved: (value) {
                    enteredname = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        onSaved: (value) {
                          enteredquantity = int.parse(value!);
                        },
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (int.tryParse(value!) == null ||
                              value.isEmpty ||
                              int.tryParse(value)! <= 0) {
                            return 'Enter valid quantity';
                          }
                          return null;
                        },
                        initialValue: '1',
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedcategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedcategory = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: !issending
                            ? () {
                                formkey.currentState!.reset();
                              }
                            : () {
                                CircularProgressIndicator();
                              },
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: !issending
                            ? () {
                                save();
                              }
                            : () {
                                CircularProgressIndicator();
//if true then disable button
                              },
                        child: const Text('Add Item'))
                  ],
                )
              ],
            ),
          )),
    );
  }
}
