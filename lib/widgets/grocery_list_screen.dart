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
// FutureBuilder is ideal in case of loading data and showing different states of data
// based upon the current state of the future.

// How ever in case of this app where we are manipulating the data FutureBuilder is not ideal
// because the builder() method of FutureBuilder is called only once in our case as future is derived from initState()
// -------------------------------------------------
// Code where FutureBuilder is used

// import 'dart:convert';

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
//   List<GroceryItem> _groceryItems = []; // list of grocery items
//   late Future<List<GroceryItem>> _loadedItems;
//   String? _errorMessage; // for a error handling

//   @override
//   void initState() {
//     super.initState();
//     _loadedItems = _loadItems();
//   }

//   Future<List<GroceryItem>> _loadItems() async {
//     // Fetch the data from the backend
//     final url = Uri.https('shopping-list-6684b-default-rtdb.firebaseio.com',
//         'shopping-list.json');
//     // try {
//     // put the code that is expected to fail in try block
//     final response = await http.get(url);

//     if (response.statusCode >= 400) {
//       throw Exception('Failed to fetch items, Please try again later.');
//     }

//     if (response.body == 'null') {
//       // setState(() {
//       //   _isLoading = false;
//       // });
//       return [];
//     }

//     // convert the response data to dart Map
//     final Map<String, dynamic> listData = json.decode(response.body);
//     final List<GroceryItem> loadedItems = [];
//     for (final item in listData.entries) {
//       // getting the category
//       final category = categories.entries
//           .firstWhere(
//               (catItem) => catItem.value.title == item.value['category'])
//           .value;
//       loadedItems.add(GroceryItem(
//         id: item.key,
//         name: item.value['name'],
//         quantity: item.value['quantity'],
//         category: category,
//       ));
//     }
//     return loadedItems;
//     // }
//     // // catch block catches the error caused by the code in try block
//     // catch (error) {
//     //   // includes the fallback code to be executed when an error occurs
//     //   setState(() {
//     //     _errorMessage = "Something went wrong!. Please try again later";
//     //   });
//     // }
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
//     final url = Uri.http('shopping-list-6684b-default-rtdb.firebaseio.com',
//         'shopping-list/${item.id}.json');
//     final response = await http.delete(url);

//     if (response.statusCode >= 400) {
//       setState(() {
//         _groceryItems.insert(index, item);
//       });
//     }
//   }

//   @override
//   Widget build(context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Groceries'),
//         actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
//       ),
//       body: FutureBuilder(
//           future: _loadedItems,
//           builder: (context, snapshot) {
//             // We don't just wanna return one widget but different widgets based on the current state of the future

//             // Initial State (Loading State)
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             // Error State
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(snapshot.error.toString()),
//               );
//             }

//             // Data loaded state (empty)
//             if (snapshot.data!.isEmpty) {
//               return Center(child: Text('No items in cart'));
//             }

//             // Data loaded state (not empty)
//             return ListView.builder(
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   return Dismissible(
//                     key: ValueKey(snapshot.data![index].id),
//                     onDismissed: (direction) {
//                       _removeItem(snapshot.data![index]);
//                     },
//                     child: ListTile(
//                       title: Text(snapshot.data![index].name),
//                       leading: Container(
//                         height: 24,
//                         width: 24,
//                         color: snapshot.data![index].category.color,
//                       ),
//                       trailing: Text(snapshot.data![index].quantity.toString()),
//                     ),
//                   );
//                 });
//           }),
//     );
//   }
// }
