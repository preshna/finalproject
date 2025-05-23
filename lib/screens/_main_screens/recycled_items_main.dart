import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:products_repository/products_repository.dart';
import 'package:waste_wise/ui/cards/product_card.dart';
import 'package:waste_wise/ui/cards/product_type_card.dart';
import 'package:waste_wise/common_network_check/dependency_injection.dart';
import 'package:waste_wise/data/dummy_data_product_type.dart';
import 'package:waste_wise/common_widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class RecycledItemsMain extends StatefulWidget {
  const RecycledItemsMain({super.key});

  @override
  State<RecycledItemsMain> createState() => RecycledItemsMainState();
}

class RecycledItemsMainState extends State<RecycledItemsMain> {
  final FocusNode _focusNode = FocusNode();
  int selectedIndex = 0;
  List<ProductModel> _products = [];
  bool isLoading = false;
  int sortingType = 1;
  Timer? _debounce;
  List<ProductModel> filteredProductsl = [];
  List<ProductModel> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProductsByType('');
    DependencyInjection.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the TextField is unfocused when the widget is first built
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    });
  }

  void _fetchSearchProducts(String query) {
    final filteredProductsm = filteredProducts
        .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _products = filteredProductsm;
      isLoading = false;
    });
  }

  void sortProducts() {
    switch (sortingType) {
      case 1:
        _products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 2:
        _products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 3:
        _products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 4:
        _products.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }

  Future<void> _fetchProductsByType(String query) async {
    try {
      setState(() {
        isLoading = true;
      });
      final productService =
      Provider.of<ProductService>(context, listen: false);
      final products = await productService.getAllProducts(sortingType);
      filteredProducts = products
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _products = filteredProducts;
        isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void _delayBackendCalls(Function func, String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Perform your backend call here
      func(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: const CustomAppBar(name: 'Recycled Products'),
      body: Column(
        children: [
          // Search bar fixed under the AppBar
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: TextField(
              onChanged: (query) {
                _delayBackendCalls(
                    _fetchSearchProducts, query); // Trigger search
              },
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: false,
              decoration: InputDecoration(
                prefixIconColor:
                isDarkMode ? Colors.white70 : const Color.fromARGB(255, 174, 174, 174),
                contentPadding: const EdgeInsets.all(8.0),
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      width: 2.0,
                      color: isDarkMode
                          ? Colors.white54
                          : const Color.fromARGB(255, 174, 174, 174)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      width: 2.0,
                      color: isDarkMode ? Colors.white : const Color.fromARGB(255, 124, 124, 124)),
                ),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black),
                hintText: 'Search Recycled Products',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 174, 174, 174),
                  fontSize: 16.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),

          // Scrollable content starts here
          Expanded(
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus(); // Unfocus TextField when tapping outside
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // Product Type ListView
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  selectedIndex = index;
                                  _delayBackendCalls(_fetchProductsByType,
                                      productTypes[index]['search']!);
                                });
                              },
                              child: ProductTypeCard(
                                  item: productTypes[index],
                                  selectedIndex: selectedIndex,
                                  index: index),
                            );
                          },
                          scrollDirection: Axis.horizontal,
                          itemCount: productTypes.length,
                        ),
                      ),

                      // Sort and product grid view section
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              productTypes[selectedIndex]['topic']!,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Material(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              color: isDarkMode ? Colors.grey[800] : Colors.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Sort By'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              selected:
                                              sortingType == 1 ? true : false,
                                              selectedColor: Colors.green[800],
                                              title: const Text('Name: A to Z'),
                                              onTap: () {
                                                setState(() {
                                                  sortingType = 1;
                                                });
                                                sortProducts();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              selected:
                                              sortingType == 2 ? true : false,
                                              selectedColor: Colors.green[800],
                                              title: const Text('Name: Z to A'),
                                              onTap: () {
                                                setState(() {
                                                  sortingType = 2;
                                                });

                                                sortProducts();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              selected:
                                              sortingType == 3 ? true : false,
                                              selectedColor: Colors.green[800],
                                              title: const Text(
                                                  'Price: Low to High'),
                                              onTap: () {
                                                setState(() {
                                                  sortingType = 3;
                                                });
                                                sortProducts();
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              selected:
                                              sortingType == 4 ? true : false,
                                              selectedColor: Colors.green[800],
                                              title: const Text(
                                                  'Price: High to Low'),
                                              onTap: () {
                                                setState(() {
                                                  sortingType = 4;
                                                });
                                                sortProducts();
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 10.0),
                                  child: const Row(
                                    children: [
                                      Text('Sort'),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.sort,
                                        size: 20.0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grid of products
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 9/15,
                              crossAxisSpacing: 15.0,
                              mainAxisSpacing: 10.0),
                          itemBuilder: (context, index) {
                            return ProductCard(item: _products[index]);
                          },
                          itemCount: _products.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
