import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceryListItem extends StatelessWidget {
  const GroceryListItem(
      {super.key, required this.groceryItem, required this.onRemoveItem});

  final GroceryItem groceryItem;
  final void Function() onRemoveItem;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(groceryItem.id),
      child: ListTile(
        title: Text(groceryItem.name),
        leading: Container(
          width: 24,
          height: 24,
          color: groceryItem.category.color,
        ),
        trailing: Text(
          groceryItem.quantity.toString(),
        ),
      ),
      onDismissed: (direction) {
        onRemoveItem();
      },
    );
    // Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    //   child: Row(
    //     children: [
    //       Container(height: 20, width: 20, color: groceryItem.category.color),
    //       const SizedBox(width: 40),
    //       Text(groceryItem.name),
    //       const Spacer(),
    //       Text(groceryItem.quantity.toString()),
    //     ],
    //   ),
    // );
  }
}
