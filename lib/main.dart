import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      home: const ShoppingListScreen(),
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class Item {
  String name;
  bool bought;

  Item({required this.name, this.bought = false});
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Item> _items = [
    Item(name: 'Milk'),
    Item(name: 'Bread'),
    Item(name: 'Rice'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      setState(() {
        _items.add(Item(name: text));
        _textController.clear();
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _toggleBought(int index) {
    setState(() {
      _items[index].bought = !_items[index].bought;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Shopping List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Add item...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.bought,
                    onChanged: (_) => _toggleBought(index),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.bought
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.bought ? Colors.grey : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
