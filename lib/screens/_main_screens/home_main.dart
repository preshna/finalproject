import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Add your other providers here if necessary
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        brightness: Brightness.light, // Light theme
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Dark theme
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[800],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white60),
          headlineSmall: TextStyle(color: Colors.white), // Ensure this is set for "Hi"
          titleMedium: TextStyle(color: Colors.white70), // Ensure this is set for "Welcome"
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.greenAccent,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      themeMode: ThemeMode.system, // Uses system theme (light or dark)
      home: const HomeMain(), // Your HomeMain widget
    );
  }
}

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, String>> vendorAds = [
    {
      'vendorName': 'Green Recycling Ltd.',
      'wasteType': 'Plastic Waste',
      'description': 'We offer best prices for your plastic waste!',
    },
    {
      'vendorName': 'Eco-Friendly Solutions',
      'wasteType': 'Organic Waste',
      'description': 'Recycle your organic waste with us and get discounts!',
    },
    {
      'vendorName': 'Tech Recyclers',
      'wasteType': 'E-Waste',
      'description': 'We safely dispose of all your electronic waste.',
    },
    {
      'vendorName': 'Metal Scrap Co.',
      'wasteType': 'Metal Waste',
      'description': 'We collect and recycle metal waste at great prices!',
    },
    {
      'vendorName': 'Paper Recycle Hub',
      'wasteType': 'Paper Waste',
      'description': 'Turn your paper waste into useful products with us.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userRepo = Provider.of<FirebaseUserRepo>(context, listen: false);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final cardColor = theme.cardColor;
    final surfaceColor = theme.colorScheme.surface;

    final List<Map<String, String>> filteredAds = vendorAds
        .where((ad) =>
    ad['vendorName']!
        .toLowerCase()
        .contains(searchQuery.toLowerCase()) ||
        ad['wasteType']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/vehicle.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          StreamBuilder<MyUser>(
                            stream: userRepo.user,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(height: 35);
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return Text(
                                  "Hi, User",
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                );
                              } else {
                                final user = snapshot.data!;
                                return Text(
                                  "Hi, ${user.name}",
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Welcome",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search vendors or waste type...',
                      fillColor: surfaceColor,
                      filled: true,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Vendors for Waste Collection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(filteredAds.length, (index) {
                  final ad = filteredAds[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ad['vendorName']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    ad['wasteType']!,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ad['description']!,
                              style: TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.info,
                                      color: theme.colorScheme.primary),
                                  label: Text(
                                    "Details",
                                    style: TextStyle(
                                        color: theme.colorScheme.primary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: surfaceColor,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.contact_page,
                                      color: theme.colorScheme.secondary),
                                  label: Text(
                                    "Contact",
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: theme.colorScheme.secondary,
                                        width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: surfaceColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
