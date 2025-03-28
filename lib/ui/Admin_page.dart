import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController _productNameController = TextEditingController();
  TextEditingController _productPriceController = TextEditingController();
  TextEditingController _productCategoryController = TextEditingController();
  TextEditingController _productDescriptionController = TextEditingController();
  TextEditingController _productImageController = TextEditingController();

  bool _isAddingProduct = false;
  List<Map<String, dynamic>> products = [];

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productCategoryController.dispose();
    _productDescriptionController.dispose();
    _productImageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch products from Firestore
  void _fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      setState(() {
        products = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Add a new product
  void _addProduct() async {
    setState(() {
      _isAddingProduct = true;
    });

    String name = _productNameController.text.trim();
    String price = _productPriceController.text.trim();
    String category = _productCategoryController.text.trim();
    String description = _productDescriptionController.text.trim();
    String imageUrl = _productImageController.text.trim();

    try {
      // Add product data to Firestore
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _productNameController.clear();
        _productPriceController.clear();
        _productCategoryController.clear();
        _productDescriptionController.clear();
        _productImageController.clear();
      });

      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product added successfully")));
    } catch (e) {
      print("Error adding product: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding product")));
    } finally {
      setState(() {
        _isAddingProduct = false;
      });
    }
  }

  // Delete a product
  void _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product deleted successfully")));
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting product")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // Add Product Section
            Text("Add Product", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(hintText: "Product Name"),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(hintText: "Product Price"),
            ),
            TextField(
              controller: _productCategoryController,
              decoration: InputDecoration(hintText: "Product Category"),
            ),
            TextField(
              controller: _productDescriptionController,
              decoration: InputDecoration(hintText: "Product Description"),
            ),
            TextField(
              controller: _productImageController,
              decoration: InputDecoration(hintText: "Product Image URL"),
            ),
            SizedBox(height: 20),
            _isAddingProduct
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _addProduct,
              child: Text("Add Product"),
            ),
            Divider(height: 30),
            // View Products Section
            Text("Products List", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: products.isEmpty
                  ? Center(child: Text("No products found"))
                  : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  String productId = product['id']; // Assuming each product has an 'id'
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Text(product['price']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProduct(productId), // Delete the product
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
