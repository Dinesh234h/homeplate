import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/matching_service.dart';
import '../services/order_service.dart';

class AppState extends ChangeNotifier {
  // Services
  final MatchingService _matchingService = MatchingService();
  final OrderService _orderService = OrderService();

  List<UserRole> roles = [];
  UserRole activeRole = UserRole.consumer;
  User? firebaseUser;
  bool isAvailable = true;
  String? userName;
  String? userAddress;
  String? phone;
  String selectedFilter = 'All';
  
  // Advanced State for "Working Buttons"
  List<String> savedAddresses = ["Home: Flat 402, Bellandur", "Work: Prestige Tech Park"];
  List<String> paymentMethods = ["UPI: avi@okaxis", "Visa ending in 4242"];
  double walletBalance = 240.0;
  List<String> likedPosts = [];

  // Preferences
  List<String> allergies = [];
  List<String> healthGoals = [];
  List<String> cuisines = [];
  String diet = 'veg';
  double spiceLevel = 50.0;
  double budgetLevel = 40.0;

  // Data
  List<Cook> cooks = [];
  List<CartItem> cart = [];
  List<Order> orders = [];
  Order? currentOrder;
  bool isLoading = false;

  AppState() {
    _initMockData();
  }

  /// F03/F04: Connected Hyperlocal Discovery
  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  List<Cook> get filteredCooks {
    List<Cook> results = List.from(cooks);
    if (selectedFilter == 'Pure Veg') {
      results = results.where((c) => c.veg).toList();
    } else if (selectedFilter == 'Top Rated') {
      results = results.where((c) => c.rating >= 4.8).toList();
    } else if (selectedFilter == 'Under ₹120') {
      results = results.where((c) => c.menu.any((d) => d.price < 120)).toList();
    }
    return results;
  }

  /// Button Logic: Addresses & Payments
  void addAddress(String addr) {
    savedAddresses.add(addr);
    notifyListeners();
  }

  void toggleLike(String postId) {
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    } else {
      likedPosts.add(postId);
    }
    notifyListeners();
  }

  /// F06: Connected Atomic Ordering
  Future<void> placeOrderReal(Cook cook, String slot) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _orderService.reserveSlot(
        cookId: cook.id.toString(),
        slotId: "evening_slot",
        quantity: 1,
      );

      if (result['success']) {
        final subtotal = cart.fold<double>(0, (sum, item) => sum + (item.price * item.qty));
        await _orderService.logCommission(cook.id.toString(), subtotal);
        placeOrder(cook, slot);
      }
    } catch (e) {
      debugPrint("Order Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setRole(UserRole newRole) {
    if (!roles.contains(newRole)) roles.add(newRole);
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
    if (address.isNotEmpty && !savedAddresses.contains(address)) {
      savedAddresses.insert(0, "Current: $address");
    }
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
    if (cart[index].qty <= 0) cart.removeAt(index);
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

  void updateStatusPublic(int orderId, String status) {
    _updateOrderStatus(orderId, status);
  }

  void toggleAvailability() {
    isAvailable = !isAvailable;
    notifyListeners();
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
      if (currentOrder?.id == orderId) currentOrder!.status = status;
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
