import 'package:flutter/material.dart';
import 'package:products_repository/products_repository.dart';
import 'package:waste_wise/common_widgets/background_image_wrapper.dart';
import 'package:waste_wise/common_widgets/custom_app_bar.dart';
import 'package:waste_wise/ui/cards/address_card.dart';
import 'package:waste_wise/ui/cards/shopping_bag_card.dart';

class ShoppingBagPage extends StatefulWidget {
  const ShoppingBagPage({super.key});

  @override
  _ShoppingBagPageState createState() => _ShoppingBagPageState();
}

class _ShoppingBagPageState extends State<ShoppingBagPage> {
  int quantity = 1;
  double singlePrice = 0.0;
  double totalPrice = 0.0;
  ProductModel item = ProductModel.empty;
  Color color = Colors.white;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    item = arguments['item']; // First argument
    singlePrice = item.price; // Single price from item
    quantity = arguments['quantity']; // Set initial quantity from arguments
    totalPrice = singlePrice * quantity; // Calculate total price
    color = arguments['color']; // Set color from arguments
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice = singlePrice * quantity; // Recalculate totalPrice
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          name: 'Shopping Bag',
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Keeps footer at the bottom
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Delivery address section
                    const AddressCard(),
                    const SizedBox(height: 10),
                    ShoppingBagCard(
                      color: color,
                      productItem: item,
                      quantity: quantity,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Single Price",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "${singlePrice.toStringAsFixed(2)} LKR",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Number of Pieces",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                    updateTotalPrice(); // Update total price
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                size: 30,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              "$quantity",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                  updateTotalPrice(); // Update total price
                                });
                              },
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 30,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order Total",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "${totalPrice.toStringAsFixed(2)} LKR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Extra space for scrollable content
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${totalPrice.toStringAsFixed(2)} LKR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/checkout', arguments: totalPrice);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.green[700] : Colors.green[600],
                      elevation: 5.0,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
