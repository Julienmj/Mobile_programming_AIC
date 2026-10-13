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
  int quantity;
  String note;
  String category;

  Item({
    required this.name,
    this.bought = false,
    this.quantity = 1,
    this.note = '',
    this.category = 'Food',
  });
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Item> _items = [
    Item(name: 'Milk'),
    Item(name: 'Bread'),
    Item(name: 'Rice'),
  ];
  String _filter = 'All';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final existingItem = _items.firstWhere(
      (item) => item.name.toLowerCase() == text.toLowerCase(),
      orElse: () => Item(name: ''),
    );

    if (existingItem.name.isNotEmpty) {
      setState(() {
        existingItem.quantity++;
      });
    } else {
      setState(() {
        _items.add(Item(name: text));
      });
    }
    _textController.clear();
  }

  void _deleteItem(int index) {
    final item = _items[index];
    final position = _items.indexOf(item);
    setState(() {
      _items.remove(item);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(position, item);
            });
          },
        ),
      ),
    );
  }

  void _toggleBought(int index) {
    setState(() {
      _items[index].bought = !_items[index].bought;
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      _items[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    if (_items[index].quantity > 1) {
      setState(() {
        _items[index].quantity--;
      });
    }
  }

  List<Item> get _filteredItems {
    final notBought = _items.where((item) => !item.bought).toList();
    final bought = _items.where((item) => item.bought).toList();

    switch (_filter) {
      case 'To buy':
        return notBought;
      case 'Bought':
        return bought;
      default:
        return [...notBought, ...bought];
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = _filteredItems;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == 'All',
                  onSelected: (_) {
                    setState(() {
                      _filter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('To buy'),
                  selected: _filter == 'To buy',
                  onSelected: (_) {
                    setState(() {
                      _filter = 'To buy';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bought'),
                  selected: _filter == 'Bought',
                  onSelected: (_) {
                    setState(() {
                      _filter = 'Bought';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'Your list is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : shown.isEmpty
                    ? const Center(
                        child: Text(
                          'Nothing here',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final item = shown[index];
                          final itemIndex = _items.indexOf(item);
                          return ListTile(
                            leading: Checkbox(
                              value: item.bought,
                              onChanged: (_) => _toggleBought(itemIndex),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.category),
                                if (item.note.isNotEmpty) Text(item.note),
                              ],
                            ),
                            onLongPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(item: item),
                                ),
                              ).then((_) {
                                setState(() {});
                              });
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _decrementQuantity(itemIndex),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _incrementQuantity(itemIndex),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteItem(itemIndex),
                                ),
                              ],
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

class DetailsScreen extends StatefulWidget {
  final Item item;

  const DetailsScreen({super.key, required this.item});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
  String _category = 'Food';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _noteController = TextEditingController(text: widget.item.note);
    _category = widget.item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() {
      widget.item.name = name;
      widget.item.note = _noteController.text.trim();
      widget.item.category = _category;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Item details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Category', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Food'),
                  selected: _category == 'Food',
                  onSelected: (_) {
                    setState(() {
                      _category = 'Food';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Drinks'),
                  selected: _category == 'Drinks',
                  onSelected: (_) {
                    setState(() {
                      _category = 'Drinks';
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Home'),
                  selected: _category == 'Home',
                  onSelected: (_) {
                    setState(() {
                      _category = 'Home';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
