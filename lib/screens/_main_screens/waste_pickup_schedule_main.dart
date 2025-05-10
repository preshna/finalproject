import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';
import 'package:waste_wise/screens/waste_pickup_schedule/waste_pickup_schedule_form.dart';
import 'package:waste_wise/screens/waste_pickup_schedule/waste_pickup_schedule_details.dart';
import 'package:provider/provider.dart';

class WastePickupScheduleMain extends StatefulWidget {
  const WastePickupScheduleMain({super.key});

  @override
  State<WastePickupScheduleMain> createState() => _WastePickupScheduleMainState();
}

class _WastePickupScheduleMainState extends State<WastePickupScheduleMain> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _deletePickup(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('waste_pickups').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup schedule canceled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel pickup schedule')),
      );
    }
  }

  Future<void> _confirmDelete(String documentId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Confirm Cancellation', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to cancel this pickup schedule?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              _deletePickup(documentId);
              Navigator.of(context).pop();
            },
            child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = Provider.of<FirebaseUserRepo>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WastePickupScheduleForm()),
          );
        },
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        elevation: 6.0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/vehicle.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<MyUser>(
                    stream: userRepo.user,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Hi, User",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
                      }
                      final user = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hi, ${user.name}",
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text("Welcome",
                              style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by Waste Type',
                      hintStyle: const TextStyle(color: Colors.white70),
                      fillColor: Colors.grey[800],
                      filled: true,
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'My Waste Pickup Schedules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('waste_pickups')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final filteredData = snapshot.data!.docs.where((pickup) {
                  return pickup['wasteType'].toString().toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final pickup = filteredData[index];
                    final pickupData = pickup.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade700),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Pickup Request",
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[800],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text("Scheduled",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Text(pickupData['scheduledDate'] ?? '',
                                      style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.delete_outline, size: 18, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Text(pickupData['wasteType'] ?? '',
                                      style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WastePickupScheduleDetails(
                                            pickup: pickupData,
                                            documentId: pickup.id,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.info, color: Colors.green.shade400),
                                    label: Text("Details", style: TextStyle(color: Colors.green.shade400)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.green.shade400),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _confirmDelete(pickup.id),
                                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                                    label: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
