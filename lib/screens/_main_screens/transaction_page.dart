import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:waste_wise/screens/transactions/transaction_details.dart';

class TransactionMain extends StatefulWidget {
  const TransactionMain({super.key});

  @override
  State<TransactionMain> createState() => _TransactionMainState();
}

class _TransactionMainState extends State<TransactionMain> {
  final FirebaseTransactions _firebaseTransactions = FirebaseTransactions();

  String searchQuery = '';
  String sortOption = "Recent";
  bool isLoading = false;
  List<TransactionsModel> allTransactions = [];
  List<TransactionsModel> filteredTransactions = [];
  Timer? debounce;

  Future<List<TransactionsModel>> _fetchTransactions() async {
    return await _firebaseTransactions.fetchTransactions();
  }

  void _filterAndSortTransactions() {
    setState(() {
      isLoading = true;
    });

    filteredTransactions = allTransactions.where((transaction) {
      return transaction.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          transaction.transactionId.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    switch (sortOption) {
      case "Recent":
        filteredTransactions.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
        break;
      case "Oldest":
        filteredTransactions.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
        break;
      case "Amount":
        filteredTransactions.sort((a, b) => b.value.compareTo(a.value));
        break;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions().then((transactions) {
      setState(() {
        allTransactions = transactions;
        filteredTransactions = transactions;
      });
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[850] : Colors.green[50];
    final borderColor = isDark ? Colors.greenAccent : Colors.green.shade600;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 210,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/vehicle.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Transaction History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        onChanged: (value) {
                          if (debounce?.isActive ?? false) debounce!.cancel();
                          debounce = Timer(const Duration(milliseconds: 300), () {
                            setState(() {
                              searchQuery = value;
                            });
                            _filterAndSortTransactions();
                          });
                        },
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.grey[900] : Colors.white,
                          hintText: "Search by title or transaction ID",
                          hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                          prefixIcon: Icon(Icons.search, color: textColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Transactions: ${filteredTransactions.length}",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: sortOption,
                  dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                  iconEnabledColor: textColor,
                  style: TextStyle(color: textColor),
                  items: <String>['Recent', 'Oldest', 'Amount']
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: textColor)),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      sortOption = value!;
                      _filterAndSortTransactions();
                    });
                  },
                ),
              ],
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          Expanded(
            child: filteredTransactions.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                var transaction = filteredTransactions[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailPage(transaction: transaction),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor!, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.payment, size: 60, color: isDark ? Colors.greenAccent : Colors.green[600]),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          transaction.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: transaction.status == 'completed'
                                              ? (isDark ? Colors.greenAccent : Colors.green)
                                              : transaction.status == 'pending'
                                              ? (isDark ? Colors.orangeAccent : Colors.orange)
                                              : (isDark ? Colors.redAccent : Colors.red),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          transaction.status.toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range, color: textColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        transaction.timestamp.toString().split(' ')[0],
                                        style: TextStyle(color: textColor),
                                      ),
                                      const SizedBox(width: 32),
                                      Icon(Icons.attach_money, color: textColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        "LKR. ${transaction.value.toStringAsFixed(2)}",
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.assignment, color: textColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        transaction.transactionId,
                                        style: TextStyle(color: textColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                'No transactions available',
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
