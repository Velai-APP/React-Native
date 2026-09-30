import 'package:flutter/material.dart';

class BusinessResultScreen extends StatelessWidget {
  const BusinessResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Business Match")),

      body: ListView(
        padding: EdgeInsets.all(20),

        children: [
          Text(
            "Your Entrepreneur Type\n\n"
            "Strategic Problem Solver",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 30),

          businessCard(
            "Financial Consulting",
            92,
            "Strong analytical ability and expertise",
          ),

          businessCard(
            "Online Training Business",
            87,
            "Teaching and communication strength",
          ),

          businessCard(
            "Compliance SaaS",
            82,
            "Problem solving and technology fit",
          ),
        ],
      ),
    );
  }

  Widget businessCard(String title, int score, String reason) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text("Fit Score : $score%"),

            SizedBox(height: 10),

            Text(reason),
          ],
        ),
      ),
    );
  }
}
