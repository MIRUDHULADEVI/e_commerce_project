import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 239, 229, 251),Color.fromARGB(255, 198, 172, 229),],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "SWIFTOO",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "At Swiftoo, we believe that life's essentials shouldn't be hard to access they should arrive at your doorstep in just minutes.\nWhat started as a mission to simplify water delivery has now evolved into a broader vision: To ensure life support essentials are available at doorstep within minutes for everyone, everywhere, regardless of economic level.\nFrom refilled RO drinking water to other vital everyday needs, we aim to bridge the gap between supply and accessibility using smart technology, hyperlocal delivery, and a socially inclusive approach.",
                style: TextStyle(fontSize: 16, height: 1.6),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 24),
              Text(
                "💡 Why Swiftoo?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 12),
              FeatureBullet("Super-fast delivery of life essentials"),
              FeatureBullet("Affordable and compliant RO water refills"),
              FeatureBullet("Eco-friendly, reusable delivery model"),
              FeatureBullet("Inclusive service for all economic segments"),
              FeatureBullet("Seamless app experience"),
              SizedBox(height: 24),
              Text(
                "🎯 Our Vision",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "To build a platform that delivers essential daily support services at lightning speed to all levels of society, creating equal access, greater convenience, and dignified living for everyone.",
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 24),
              Text(
                "📬 Contact Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text("support@xyz.com"),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.language, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text("www.xyz.com"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureBullet extends StatelessWidget {
  final String text;
  const FeatureBullet(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
