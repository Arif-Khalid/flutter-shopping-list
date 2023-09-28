import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItemScreen extends StatelessWidget {
  NewItemScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String enteredName = '';
    int enteredQuantity = 1;
    Category selectedCategory = categories[Categories.vegetables]!;
    bool isSending = false;
    void saveItem() async {
      if (isSending) return;
      if (_formKey.currentState!.validate()) {
        isSending = true;
        _formKey.currentState!.save();
        final url = Uri.https(
            'flutter-prep-2964f-default-rtdb.asia-southeast1.firebasedatabase.app',
            'shopping-list.json');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': enteredName,
            'quantity': enteredQuantity,
            'category': selectedCategory.name,
          }),
        );
        if (!context.mounted) return;
        final Map<String, dynamic> resData = json.decode(response.body);
        isSending = false;
        Navigator.of(context).pop(
          GroceryItem(
            id: resData['name'],
            name: enteredName,
            quantity: enteredQuantity,
            category: selectedCategory,
          ),
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Add a new item'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return "Must be between 2 and 50 characters";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    enteredName = newValue!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: '1',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return "Must be a valid, positive number";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          enteredQuantity = int.parse(newValue!);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: categories[Categories.vegetables],
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(category.value.name),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          selectedCategory = value!;
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (isSending) return;
                        print('I am resetting');
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: saveItem,
                      child: const Text('Add Item'),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
