import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_list_item.dart';
import 'package:shopping_list/screens/new_item.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.push(
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

  void _removeItem(GroceryItem groceryItem) {
    setState(() {
      _groceryItems.remove(groceryItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeWidget;
    if (_groceryItems.isEmpty) {
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
