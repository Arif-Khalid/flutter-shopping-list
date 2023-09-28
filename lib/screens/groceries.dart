import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_list_item.dart';
import 'package:shopping_list/screens/new_item.dart';
import 'package:http/http.dart' as http;

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  bool _isLoading = true;
  String? _error;
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-2964f-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
        return;
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> newGroceryItems = [
        for (final item in listData.entries)
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: categories.entries
                .firstWhere(
                    (element) => element.value.name == item.value['category'])
                .value,
          ),
      ];
      setState(() {
        _groceryItems = newGroceryItems;
        _isLoading = false;
      });
    } catch (err) {
      _error = 'Something went wrong. Please try again later';
    }
  }

  void _addItem() async {
    GroceryItem? newItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewItemScreen(),
      ),
    );

    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);
    setState(() {
      _groceryItems.remove(groceryItem);
    });

    final url = Uri.https(
        'flutter-prep-2964f-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${groceryItem.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // TODO show an error message
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget activeWidget;
    if (_error != null) {
      activeWidget = Center(
        child: Text(_error!),
      );
    } else if (_isLoading) {
      activeWidget = const Center(child: CircularProgressIndicator());
    } else if (_groceryItems.isEmpty) {
      activeWidget = const Center(
        child: Text('You have no items 🥲'),
      );
    } else {
      activeWidget = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => GroceryListItem(
          groceryItem: _groceryItems[index],
          onRemoveItem: () {
            _removeItem(_groceryItems[index]);
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: activeWidget,
    );
  }
}
