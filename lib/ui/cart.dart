import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plants_app/ui/plants%20detailspage.dart';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CartPage({Key? key, required this.cart}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid; // Current user ID

  String? _paymentMethod = 'COD'; // Default payment method: Cash on Delivery
  String? _phone;
  String? _address;

  double _calculateTotalPrice() {
    return widget.cart.fold(
      0,
          (sum, plant) => sum + double.parse(plant['price'].replaceAll('\$', '')),
    );
  }

  Future<void> _updateCartInFirestore() async {
    await _firestore.collection('users').doc(userId).update({
      'cart': widget.cart, // Update cart in Firestore
    });
  }

  Future<void> _addToBuyedPlants(Map<String, dynamic> plant) async {
    await _firestore.collection('users').doc(userId).collection('buyed_plants').add({
      'plant': plant['name'],
      'price': plant['price'],
      'address': _address,
      'phone': _phone,
      'status': 'Purchased',
      'payment_method': 'COD',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900],
        elevation: 0,
      ),
      body: widget.cart.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final plant = widget.cart[index];
                return _buildPlantCard(context, plant, index);
              },
            ),
          ),
          _buildBuyButton(context),
        ],
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, Map<String, dynamic> plant,
      int index) {
    return GestureDetector(
      onTap: () {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(plant['image'], width: 50, height: 50, fit: BoxFit.cover),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant['price'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        widget.cart.removeAt(index);
                      });
                      _updateCartInFirestore(); // Update Firestore
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item removed from cart!")),
                      );
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _showCODDialogForItem(context, plant, index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[900],
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text(
                      "Buy",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCODDialogForItem(BuildContext context, Map<String, dynamic> plant, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Delivery Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _phone = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _address = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Delivery Address"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_phone != null && _address != null) {
                  await _processCODPaymentForItem(context, plant, index);
                  Navigator.pop(context); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processCODPaymentForItem(BuildContext context, Map<String, dynamic> plant, int index) async {
    try {
      await _addToBuyedPlants(plant);
      setState(() {
        widget.cart.removeAt(index); // Remove item from the cart
      });
      _updateCartInFirestore();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("COD order placed for ${plant['name']}!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing order: $e")),
      );
    }
  }

  Future<void> _processCODPaymentForCart(BuildContext context) async {
    try {
      await _firestore.collection('users').doc(userId).collection('orders').add({
        'cart': widget.cart.map((plant) {
          return {
            'plant': plant['name'],
            'price': plant['price'],
            'address': _address,
            'phone': _phone,
            'status': 'Pending',
            'payment_method': 'COD',
            'timestamp': FieldValue.serverTimestamp(),
          };
        }).toList(),
        'totalPrice': _calculateTotalPrice(),
        'payment_method': 'COD',
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        widget.cart.clear(); // Clear cart after the order is placed
      });
      await _updateCartInFirestore();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cash on Delivery order placed for entire cart!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing Cash on Delivery payment: $e")),
      );
    }
  }

  Widget _buildBuyButton(BuildContext context) {
    final totalPrice = _calculateTotalPrice();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total: \$${totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          ElevatedButton(
            onPressed: widget.cart.isEmpty
                ? null
                : () async {
              _showCODDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[900],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "Buy",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCODDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Delivery Information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _phone = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _address = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Delivery Address"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_phone != null && _address != null) {
                  await _processCODPaymentForCart(context);
                  Navigator.pop(context); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}
