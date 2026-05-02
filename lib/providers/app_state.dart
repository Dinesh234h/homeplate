import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';

class AppState extends ChangeNotifier {
  List<UserRole> roles = [];
  UserRole activeRole = UserRole.consumer;
  User? firebaseUser;
  bool isAvailable = true;
  String? userName;
  String? userAddress;
  String? phone;
  List<String> allergies = [];
  List<String> healthGoals = [];
  List<String> cuisines = [];
  String diet = 'veg';
  double spiceLevel = 50.0;
  double budgetLevel = 40.0;

  List<Cook> cooks = [];
  List<CartItem> cart = [];
  List<Order> orders = [];
  Order? currentOrder;
  double wallet = 240.0;

  AppState() {
    _initMockData();
  }

  void setRole(UserRole newRole) {
    if (!roles.contains(newRole)) {
      roles.add(newRole);
    }
    activeRole = newRole;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (roles.contains(newRole)) {
      activeRole = newRole;
      notifyListeners();
    }
  }

  void setFirebaseUser(User? user) {
    firebaseUser = user;
    notifyListeners();
  }

  void setAvailability(bool val) {
    isAvailable = val;
    notifyListeners();
  }

  void setUserInfo(String name, String address) {
    userName = name;
    userAddress = address;
    notifyListeners();
  }

  void setPhone(String p) {
    phone = p;
    notifyListeners();
  }

  void addToCart(Cook cook, Dish dish, int qty) {
    if (cart.isNotEmpty && cart[0].cookId != cook.id) {
      cart.clear();
    }
    
    final existingIndex = cart.indexWhere((item) => item.dishId == dish.id);
    if (existingIndex >= 0) {
      cart[existingIndex].qty += qty;
    } else {
      cart.add(CartItem(
        cookId: cook.id,
        dishId: dish.id,
        name: dish.name,
        emoji: dish.emoji,
        bg: dish.bg,
        price: dish.price,
        qty: qty,
      ));
    }
    notifyListeners();
  }

  void updateCartQty(int index, int delta) {
    cart[index].qty += delta;
    if (cart[index].qty <= 0) {
      cart.removeAt(index);
    }
    notifyListeners();
  }

  void placeOrder(Cook cook, String slot) {
    final total = cart.fold<double>(0, (sum, item) => sum + (item.price * item.qty));
    final order = Order(
      id: 1000 + (DateTime.now().millisecondsSinceEpoch % 9000),
      cookId: cook.id,
      cookName: cook.name,
      cookShort: cook.short,
      cookAvatar: cook.avatar,
      cookColors: [cook.c1, cook.c2],
      cookDist: cook.distance,
      cookWalk: cook.walkMin,
      cookAddr: cook.addr,
      items: List.from(cart),
      total: total,
      otp: (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString(),
      slot: slot,
      status: 'placed',
      placedAt: DateTime.now().millisecondsSinceEpoch,
      customerName: userName ?? 'Customer',
    );
    
    orders.insert(0, order);
    currentOrder = order;
    cart.clear();
    notifyListeners();
    
    _simulateOrderProgress(order.id);
  }

  void _simulateOrderProgress(int orderId) {
    Future.delayed(const Duration(seconds: 5), () => _updateOrderStatus(orderId, 'accepted'));
    Future.delayed(const Duration(seconds: 12), () => _updateOrderStatus(orderId, 'cooking'));
    Future.delayed(const Duration(seconds: 25), () => _updateOrderStatus(orderId, 'ready'));
  }

  void _updateOrderStatus(int orderId, String status) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      orders[index].status = status;
      if (currentOrder?.id == orderId) {
        currentOrder!.status = status;
      }
      notifyListeners();
    }
  }

  void _initMockData() {
    cooks = [
      Cook(
        id: 0,
        name: "Neha's Kitchen",
        short: "Neha",
        avatar: "👩‍🍳",
        tagline: "Authentic North Indian Home Food",
        rating: 4.8,
        ratingCount: 124,
        years: 8,
        distance: 0.8,
        walkMin: 10,
        addr: "Flat 402, Green Glen Layout, Bellandur",
        c1: const Color(0xFFFF6B47),
        c2: const Color(0xFFF4B942),
        fssai: true,
        inspected: true,
        top: true,
        cookOfMonth: false,
        veg: false,
        cuisines: ["North Indian", "Punjabi"],
        menu: [
          Dish(
            id: "d1",
            name: "Rajma + Jeera Rice",
            desc: "Slow cooked kidney beans in thick gravy with aromatic rice",
            emoji: "🍛",
            price: 110,
            rating: 4.9,
            orders: 840,
            veg: true,
            bg: "#FFE8E0",
            hbg: "linear-gradient(135deg, #FF6B47, #F4B942)",
            ingredients: "Rajma, Basmati Rice, Onion, Tomato, Spices",
            allergens: ["Dairy"],
            nutri: [Nutrient("Cal", "420"), Nutrient("Prot", "14g"), Nutrient("Carb", "62g")],
          ),
          Dish(
            id: "d2",
            name: "Palak Paneer + 2 Roti",
            desc: "Fresh spinach puree with soft cottage cheese cubes",
            emoji: "🥘",
            price: 140,
            rating: 4.7,
            orders: 620,
            veg: true,
            bg: "#E3F0E8",
            hbg: "linear-gradient(135deg, #2D5F3F, #5DAA75)",
            ingredients: "Spinach, Paneer, Whole Wheat, Spices",
            allergens: ["Dairy", "Gluten"],
            nutri: [Nutrient("Cal", "380"), Nutrient("Prot", "18g"), Nutrient("Carb", "32g")],
          ),
        ],
      ),
      Cook(
        id: 1,
        name: "Priya's Traditional",
        short: "Priya",
        avatar: "👩",
        tagline: "South Indian delicacies from my grandmother's recipe",
        rating: 4.9,
        ratingCount: 210,
        years: 12,
        distance: 1.2,
        walkMin: 15,
        addr: "House 12, 4th Cross, Bellandur",
        c1: const Color(0xFF2D5F3F),
        c2: const Color(0xFF5DAA75),
        fssai: true,
        inspected: false,
        top: true,
        cookOfMonth: true,
        veg: true,
        cuisines: ["South Indian", "Healthy"],
        menu: [
          Dish(
            id: "d3",
            name: "Bisi Bele Bath",
            desc: "Hot lentil rice with mixed vegetables and special spice mix",
            emoji: "🍚",
            price: 90,
            rating: 4.9,
            orders: 1200,
            veg: true,
            bg: "#E3F0E8",
            hbg: "linear-gradient(135deg, #2D5F3F, #5DAA75)",
            ingredients: "Rice, Lentils, Vegetables, Tamarind, Spices",
            allergens: [],
            nutri: [Nutrient("Cal", "350"), Nutrient("Prot", "12g"), Nutrient("Carb", "58g")],
          ),
        ],
      ),
    ];
  }
}
