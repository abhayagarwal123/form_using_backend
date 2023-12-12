import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummyitem.dart';
import 'package:shopping_list/widget/new_item.dart';
import 'package:http/http.dart' as http;

import '../model/grocery_item.dart';

class GroceryList extends StatefulWidget {
  GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> grocerylist = [];
  String? errormessage;
  void alert(GroceryItem grc, int index) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Item Removed!!!'),

    ));
  }

  @override
  //it is done to get all data while we open app for the first time
  void initState() {
    super.initState();
    loaditem();
  }

  void loaditem() async {
    final url = Uri.https(
        'flutter-prep-eab00-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      setState(() {
        errormessage = 'fail to fetch data';
      });
    }
    final Map<String, dynamic> listdata = json.decode(response.body);
    List<GroceryItem> loadeditem = [];
    for (final item in listdata.entries) {
      final cat = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      loadeditem.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: cat));
    }

    setState(() {
      grocerylist = loadeditem;
    });
  }

  void addItem() async {
    final newdata = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );
    if (newdata == null) {
      return;
    }
    setState(() {
      grocerylist.add(newdata);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  addItem();
                },
                icon: const Icon(Icons.add))
          ],
          title: Text(
            'Groceries list',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 30),
          )),
      body: errormessage != null
          ? Text(errormessage!)
          : grocerylist.isEmpty
              ? const Center(
                  child: Text(
                  'No grocery item....Try adding some',
                  style: TextStyle(fontSize: 20),
                ))
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: ValueKey(grocerylist[index].id),
                      onDismissed: (Direction) {
                        setState(() {
                          alert(grocerylist[index], index);
                          final url = Uri.https(
                              'flutter-prep-eab00-default-rtdb.firebaseio.com',
                              'shopping-list/${grocerylist[index].id}.json');
                          http.delete(url);
                          grocerylist.remove(grocerylist[index]);
                        });
                      },
                      child: ListTile(
                        title: Text(
                          grocerylist[index].name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        leading: Container(
                          width: 25,
                          height: 25,
                          color: grocerylist[index].category.color,
                        ),
                        trailing: Text(grocerylist[index].quantity.toString(),
                            style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  },
                  itemCount: grocerylist.length),
    );
  }
}
