import 'package:flutter/material.dart';

import 'home page.dart';

void main() {
  runApp(OnboardingScreen());
}

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LearnMoreAboutPlantsScreen(),
    );
  }
}

class LearnMoreAboutPlantsScreen extends StatefulWidget {
  @override
  _LearnMoreAboutPlantsScreenState createState() =>
      _LearnMoreAboutPlantsScreenState();
}

class _LearnMoreAboutPlantsScreenState
    extends State<LearnMoreAboutPlantsScreen> {
  // List of image paths
  final List<String> plantImages = [
    'asset/image/plant1.jpg', // Replace with your plant image asset paths
    'asset/image/plant2.jpg',
    'asset/image/Aquatic plants.jpeg', // Added a third image for demonstration
  ];

  int currentIndex = 0; // Track current image index

  void _showNextImage() {
    setState(() {
      currentIndex = (currentIndex + 1) % plantImages.length; // Loop to the next image
    });

    // If the last image is shown, navigate to the next screen
    if (currentIndex == 0) {
      _navigateToNextScreen();
    }
  }

  void _skipOnboarding() {
    // Navigate to the next screen directly
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Navigate to the next screen (for example, Plant Store home page)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlantStoreHomePage()), // Replace with your next screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              "Skip",
              style: TextStyle(color: Colors.green[900], fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              plantImages[currentIndex], // Dynamically show the current image
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Learn more about plants',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Read how to care for plants in\nour rich plants guide.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      plantImages.length,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: currentIndex == index
                              ? Colors.green[900] // Highlight the current dot
                              : Colors.grey, // Other dots
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Colors.green[900],
                      padding: EdgeInsets.all(15),
                    ),
                    onPressed: _showNextImage, // Update image and dot on button press
                    child: Icon(
                      currentIndex == plantImages.length - 1
                          ? Icons.check // Show check icon at the last image
                          : Icons.arrow_forward,
                      color: Colors.white,
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

