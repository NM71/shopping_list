import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<GroceryItem> _groceryItems = []; // list of grocery items
  var _isLoading = true; // loading spinner state
  String? _errorMessage; // for a error handling

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    // Fetch the data from the backend
    final url = Uri.https('shopping-list-6684b-default-rtdb.firebaseio.com',
        'shopping-list.json');
    try {
      // put the code that is expected to fail in try block
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _errorMessage = "Failed to load data. Please try again later";
          _isLoading = false;
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // convert the response data to dart Map
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        // getting the category
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    }
    // catch block catches the error caused by the code in try block
    catch (error) {
      // includes the fallback code to be executed when an error occurs
      setState(() {
        _errorMessage = "Something went wrong!. Please try again later";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const NewItemScreen(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    // _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.http('shopping-list-6684b-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(context) {
    Widget content = Center(child: Text('No items in cart'));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: ValueKey(_groceryItems[index].id),
              onDismissed: (direction) {
                _removeItem(_groceryItems[index]);
              },
              child: ListTile(
                title: Text(_groceryItems[index].name),
                leading: Container(
                  height: 24,
                  width: 24,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(_groceryItems[index].quantity.toString()),
              ),
            );
          });
    }

    if (_errorMessage != null) {
      content = Center(
        child: Text(_errorMessage!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}

// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/models/grocery_item.dart';
// import 'package:shopping_list/widgets/new_item.dart';
// import 'package:http/http.dart' as http;

// class GroceryListScreen extends StatefulWidget {
//   const GroceryListScreen({super.key});

//   @override
//   State<GroceryListScreen> createState() => _GroceryListScreenState();
// }

// class _GroceryListScreenState extends State<GroceryListScreen> {
//   List<GroceryItem> _groceryItems = [];
//   var _isLoading = true;
//   String? _errorMessage; // for a error handling

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   void _loadItems() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Fetch the data from the backend
//       // Use your actual Firebase URL for production
//       final url = Uri.https('shopping-list-6684b-default-rtdb.firebaseio.com',
//           'shopping-list.json');
//       final response = await http.get(url);

//       if (response.statusCode >= 400) {
//         setState(() {
//           _errorMessage = "Failed to load data. Please try again later";
//           _isLoading = false;
//         });
//         return;
//       }

//       // Check if response body is null or empty

//       // Important: Firebase returns a String 'null' when there is no data
//       // Actually Firebase returns a String 'null' when there is no data
//       // So we need to check if the response body is 'null' string, not null keyword
//       if (response.body == 'null') {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // convert the response data to dart Map
//       final Map<String, dynamic> listData = json.decode(response.body);
//       final List<GroceryItem> loadedItems = [];

//       if (listData != null && listData.isNotEmpty) {
//         for (final item in listData.entries) {
//           try {
//             // getting the category
//             final category = categories.entries
//                 .firstWhere(
//                     (catItem) => catItem.value.title == item.value['category'])
//                 .value;
//             loadedItems.add(GroceryItem(
//               id: item.key,
//               name: item.value['name'],
//               quantity: item.value['quantity'],
//               category: category,
//             ));
//           } catch (err) {
//             if (kDebugMode) {
//               print('Error processing item ${item.key}: $err');
//             }
//             // Continue with the next item
//           }
//         }
//       }

//       setState(() {
//         _groceryItems = loadedItems;
//         _isLoading = false;
//       });
//     } catch (error) {
//       setState(() {
//         _errorMessage = "Something went wrong! ${error.toString()}";
//         _isLoading = false;
//       });
//     }
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       PageTransition(
//         type: PageTransitionType.bottomToTop,
//         child: const NewItemScreen(),
//       ),
//     );
//     if (newItem == null) {
//       return;
//     }
//     setState(() {
//       _groceryItems.add(newItem);
//     });
//     // _loadItems();
//   }

//   void _removeItem(GroceryItem item) async {
//     final index = _groceryItems.indexOf(item);
//     setState(() {
//       _groceryItems.remove(item);
//     });

//     try {
//       final url = Uri.https('shopping-list-6684b-default-rtdb.firebaseio.com',
//           'shopping-list/${item.id}.json');
//       final response = await http.delete(url);

//       if (response.statusCode >= 400) {
//         // Show error and restore the item
//         if (context.mounted) {
//           return;
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to delete item. Please try again.'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         setState(() {
//           if (index >= 0) {
//             _groceryItems.insert(index, item);
//           }
//         });
//       }
//     } catch (error) {
//       // Show error and restore the item
//       if (context.mounted) {
//         return;
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to delete item. Please try again.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       setState(() {
//         if (index >= 0) {
//           _groceryItems.insert(index, item);
//         }
//       });
//     }
//   }

//   @override
//   Widget build(context) {
//     Widget content = const Center(child: Text('No items added yet.'));

//     if (_isLoading) {
//       content = const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_groceryItems.isNotEmpty) {
//       content = ListView.builder(
//           itemCount: _groceryItems.length,
//           itemBuilder: (context, index) {
//             return Dismissible(
//               key: ValueKey(_groceryItems[index].id),
//               onDismissed: (direction) {
//                 _removeItem(_groceryItems[index]);
//               },
//               background: Container(
//                 color: Colors.red.shade400,
//                 alignment: Alignment.centerRight,
//                 padding: const EdgeInsets.only(right: 20),
//                 margin: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 4,
//                 ),
//                 child: const Icon(
//                   Icons.delete,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               child: ListTile(
//                 title: Text(_groceryItems[index].name),
//                 leading: Container(
//                   height: 24,
//                   width: 24,
//                   color: _groceryItems[index].category.color,
//                 ),
//                 trailing: Text(_groceryItems[index].quantity.toString()),
//               ),
//             );
//           });
//     }

//     if (_errorMessage != null) {
//       content = Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _errorMessage!,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.error,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextButton(
//               onPressed: _loadItems,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Groceries'),
//         actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
//       ),
//       body: content,
//     );
//   }
// }
