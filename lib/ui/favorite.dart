import 'package:flutter/material.dart';
import 'package:plants_app/ui/plants%20detailspage.dart';

class FavoritePage extends StatelessWidget {
  final List<Map<String, dynamic>> favoritePlants;

  const FavoritePage({Key? key, required this.favoritePlants}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green[900],
        elevation: 0,
      ),
      body: favoritePlants.isEmpty
          ? const Center(child: Text("No favorites yet!"))
          : ListView.builder(
        itemCount: favoritePlants.length,
        itemBuilder: (context, index) {
          final plant = favoritePlants[index];
          return _buildPlantCard(context, plant);
        },
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () {
        // Navigate to plant details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailsPage(plant: plant),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Image.asset(plant['image'], width: 50, height: 50, fit: BoxFit.cover),
          title: Text(plant['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(plant['price']),
        ),
      ),
    );
  }
}
