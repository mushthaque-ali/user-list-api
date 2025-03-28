import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:plants_app/login/login_ui/login_page.dart';
import '../login/glogel/common/toast.dart';
import 'cart.dart';
import 'favorite.dart';
import 'package:plants_app/ui/plants%20detailspage.dart';
import 'package:plants_app/ui/profile%20page.dart';


class PlantStoreHomePage extends StatefulWidget {
  const PlantStoreHomePage({Key? key}) : super(key: key);

  @override
  _PlantStoreHomePageState createState() => _PlantStoreHomePageState();
}

class _PlantStoreHomePageState extends State<PlantStoreHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchcontroller = TextEditingController();

  final List<Map<String, dynamic>> _cart = [];
  final List<Map<String, dynamic>> _favoritePlants = [];
  final List<Map<String, dynamic>> _plants = [
    {
      'name': 'Lucky Bamboo Plant',
      'price': '\$15.00',
      'rating': '4.0',
      'image': 'asset/image/Bamboos.jpeg',
      'description':
      'The Lucky Bamboo plant is believed to bring good fortune, health, and positive energy. It is easy to care for and thrives in a variety of environments.',
      'category': 'All',
      'isFavorite': false,
    },
    {
      'name': 'House plants',
      'price': '\$15.00',
      'rating': '3.5',
      'image': 'asset/image/House plants.jpeg',
      'description':
      'Houseplants are great for decorating interiors and improving indoor air quality. They require minimal maintenance and brighten up any space.',
      'category': 'Indoor',
      'isFavorite': false,
    },
    {
      'name': 'Aquatic Plants',
      'price': '\$25.00',
      'rating': '3.0',
      'image': 'asset/image/Aquatic plants.jpeg',
      'description':
      'Aquatic plants are perfect for aquariums and ponds. They help maintain water quality and provide a natural habitat for aquatic life.',
      'category': 'Popular',
      'isFavorite': false,
    },
    {
      'name': 'Cactus & Succulents',
      'price': '\$35.00',
      'rating': '4.0',
      'image': 'asset/image/Catus & Succulents.jpeg',
      'description':
      'Cactus and succulents are low-maintenance plants that are perfect for beginners. They come in various shapes and sizes and can thrive in minimal water conditions.',
      'category': 'Indoor',
      'isFavorite': false,
    },
    {
      'name': 'Climbers',
      'price': '\$15.00',
      'rating': '4.5',
      'image': 'asset/image/Climbers.jpeg',
      'description':
      'Climbers are versatile plants that add greenery to vertical spaces. They are ideal for decorating fences, walls, and pergolas.',
      'category': 'Outdoor',
      'isFavorite': false,
    },
  ];
  List<Map<String, dynamic>> _filteredPlants = [];
  String selectedCategory = 'All';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredPlants = _plants;
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final user = _auth.currentUser;
    if (user != null) {
      final cartDocs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();
      setState(() {
        _cart.clear();
        _cart.addAll(cartDocs.docs.map((doc) => doc.data()));
      });
    }
  }

  Future<void> _addToCart(Map<String, dynamic> plant) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add(plant);
      setState(() {
        _cart.add(plant);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added to cart!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add items to your cart.")),
      );
    }
  }
  String _getUserName() {
    final user = _auth.currentUser;
    return user?.displayName ?? user?.email ?? 'Plant Enthusiast';
  }


  void _filterPlants(String query) {
    final filtered = _plants
        .where((plant) =>
    plant['name'].toLowerCase().contains(query.toLowerCase()) &&
        (plant['category'] == selectedCategory || selectedCategory == 'All'))
        .toList();
    setState(() {
      _filteredPlants = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.spa, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              "Plantae",
              style: TextStyle(
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: _getBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[900],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green[900]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _getUserName(),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', 0),
          _buildDrawerItem(Icons.person, 'Profile', 3),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
              );
              showToast(message: "Successfully signed out");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green[900],
      unselectedItemColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
        BottomNavigationBarItem(
          icon: badges.Badge(
            showBadge: _cart.isNotEmpty,
            badgeContent: Text(
              '${_cart.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: const Icon(Icons.shopping_cart),
          ),
          label: "Cart",
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }

  Widget _getBody() {
    if (_currentIndex == 1) {
      return FavoritePage(favoritePlants: _favoritePlants);
    } else if (_currentIndex == 2) {
      return CartPage(cart: _cart);
    } else if (_currentIndex == 3) {
      return const ProfilePage();
    } else {
      return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategoryTabs(),
          const SizedBox(height: 16),
          _buildPlantGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchcontroller,
        onChanged: _filterPlants,
        decoration: InputDecoration(
          hintText: "Find Plant",
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryTab("All"),
          _buildCategoryTab("Popular"),
          _buildCategoryTab("Indoor"),
          _buildCategoryTab("Outdoor"),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String label) {
    final isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
          _filterPlants(_searchcontroller.text);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.green[900] : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlantGrid() {
    final filteredPlants = _filteredPlants
        .where((plant) =>
    plant['category'] == selectedCategory || selectedCategory == 'All')
        .toList();

    return Expanded(
      child: GridView.builder(
        itemCount: filteredPlants.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final plant = filteredPlants[index];
          return _buildPlantCard(plant);
        },
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantDetailsPage(plant: plant),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(plant['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        plant['isFavorite'] = !plant['isFavorite'];
                        if (plant['isFavorite']) {
                          _favoritePlants.add(plant);
                        } else {
                          _favoritePlants.removeWhere(
                                  (favPlant) => favPlant['name'] == plant['name']);
                        }
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        plant['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant['price'],
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(plant['rating']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _addToCart(plant);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add to Cart',
                        style: TextStyle(color: Colors.white),
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
