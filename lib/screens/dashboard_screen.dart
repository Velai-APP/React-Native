import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'domain_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? "No Name"),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Domains"),
              onTap: () {
                Navigator.pop(context);
                // Add your DomainScreen navigation here
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Reminders"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Service",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Choose a service to continue",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _serviceCard(
                    context,
                    icon: Icons.language,
                    title: "Domain Management",
                    subtitle: "Manage domains, expiry dates & reminders",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DomainManagementScreen(),
                        ),
                      );
                    },
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.receipt_long,
                    title: "GST Compliance",
                    subtitle: "GST return reminders & notices",
                    color: Colors.green,
                    onTap: () {},
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.account_balance,
                    title: "Income Tax",
                    subtitle: "Income Tax compliance & notices",
                    color: Colors.orange,
                    onTap: () {},
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.business,
                    title: "MCA Compliance",
                    subtitle: "ROC filings & annual compliance",
                    color: Colors.deepPurple,
                    onTap: () {},
                  ),

                  _serviceCard(
                    context,
                    icon: Icons.notifications_active,
                    title: "Reminders",
                    subtitle: "Upcoming compliance reminders",
                    color: Colors.red,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _serviceCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 30),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 55)
                      : null,
                ),

                const SizedBox(height: 20),

                Text(
                  user?.displayName ?? "No Name",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  user?.email ?? "No Email",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const Divider(height: 40),

                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text("Email Verified"),
                  trailing: Text(user?.emailVerified == true ? "Yes" : "No"),
                ),

                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone Number"),
                  trailing: Text(user?.phoneNumber ?? "Not Available"),
                ),

                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text("Login Provider"),
                  trailing: Text(
                    user?.providerData.isNotEmpty == true
                        ? user!.providerData.first.providerId
                        : "-",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
