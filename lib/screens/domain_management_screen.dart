import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velai/screens/notification.dart' show NotificationService;

import 'add_domain_screen.dart';


class DomainManagementScreen extends StatelessWidget {
  const DomainManagementScreen({super.key});

  String getStatus(DateTime expiryDate) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;

    if (daysLeft < 0) {
      return "Expired";
    } else if (daysLeft <= 30) {
      return "Expiring";
    } else {
      return "Active";
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Domain Management"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Domain"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddDomainScreen(),
            ),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("domains")
            .where("userId", isEqualTo: userId)
            .orderBy("expiryDate")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          int total = docs.length;
          int expired = 0;
          int expiring = 0;
          int active = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final expiry =
                (data["expiryDate"] as Timestamp).toDate();

            final days =
                expiry.difference(DateTime.now()).inDays;

            if (days < 0) {
              expired++;
            } else if (days <= 30) {
              expiring++;
            } else {
              active++;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Domain Overview",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),



                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _dashboardCard(
                        "Total",
                        total.toString(),
                        Colors.blue,
                        Icons.language,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dashboardCard(
                        "Expiring",
                        expiring.toString(),
                        Colors.orange,
                        Icons.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _dashboardCard(
                        "Expired",
                        expired.toString(),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dashboardCard(
                        "Active",
                        active.toString(),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "My Domains",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: docs.isEmpty
                      ? const Center(
                          child: Text(
                            "No domains added yet.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data()
                                as Map<String, dynamic>;

                            final expiry =
                                (data["expiryDate"] as Timestamp)
                                    .toDate();

                            final days =
                                expiry.difference(DateTime.now()).inDays;

                            final status = getStatus(expiry);

                            return  Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        data["domainName"].toString()[0].toUpperCase(),
                      ),
                    ),

                    title: Text(
                      data["domainName"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      days < 0
                          ? "Expired ${days.abs()} days ago"
                          : "Expires in $days days",
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == "edit") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddDomainScreen(
                                docId: docs[index].id,
                                existingData: data,
                              ),
                            ),
                          );
                        }

                        if (value == "delete") {
                          await FirebaseFirestore.instance
                              .collection("domains")
                              .doc(docs[index].id)
                              .delete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text("Edit"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dashboardCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 35,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }
}