import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/order_service.dart';

class AppState extends ChangeNotifier {
  // Services
  final OrderService _orderService = OrderService();

  List<UserRole> roles = [];
  UserRole activeRole = UserRole.consumer;
  User? firebaseUser;
  bool isAvailable = true;
  String? userName = "Avi Nash";
  String? userAddress = "Flat 402, Green Glen Layout, Bellandur";
  String? phone = "+91 9876543210";
  String selectedFilter = 'All';
  String searchQuery = '';
  
  // Advanced State
  List<String> savedAddresses = ["Home: Flat 402, Bellandur", "Work: Prestige Tech Park"];
  List<String> paymentMethods = ["UPI: avi@okaxis", "Visa ending in 4242", "Cash on Delivery (COD)"];
  String selectedPayment = "UPI: avi@okaxis";
  double walletBalance = 500.0;
  List<String> likedPosts = [];
  
  // Plans State
  String? activePlanName = "Daily Lunch Box";
  DateTime? planDueDate = DateTime.now().add(const Duration(days: 15));

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

  void setSearchQuery(String q) {
    searchQuery = q.toLowerCase();
    notifyListeners();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  List<Cook> get filteredCooks {
    List<Cook> results = cooks.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(searchQuery) || 
                            c.menu.any((d) => d.name.toLowerCase().contains(searchQuery));
      return matchesSearch;
    }).toList();

    if (selectedFilter == 'Pure Veg') {
      results = results.where((c) => c.veg).toList();
    } else if (selectedFilter == 'Top Rated') {
      results = results.where((c) => c.rating >= 4.8).toList();
    } else if (selectedFilter == 'Under ₹120') {
      results = results.where((c) => c.menu.any((d) => d.price < 120)).toList();
    }
    return results;
  }

  void addAddress(String addr) {
    savedAddresses.add(addr);
    notifyListeners();
  }

  void updateAddress(int index, String newAddr) {
    savedAddresses[index] = newAddr;
    if (userAddress == savedAddresses[index]) userAddress = newAddr;
    notifyListeners();
  }

  void setPaymentMethod(String p) {
    selectedPayment = p;
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

  void subscribeToPlan(String plan) {
    activePlanName = plan;
    planDueDate = DateTime.now().add(const Duration(days: 30));
    notifyListeners();
  }

  void reorder(Order order) {
    cart.clear();
    for (var item in order.items) {
      cart.add(CartItem(
        cookId: item.cookId,
        dishId: item.dishId,
        name: item.name,
        emoji: item.emoji,
        bg: item.bg,
        price: item.price,
        qty: item.qty,
      ));
    }
    notifyListeners();
  }

  Future<void> placeOrderReal(Cook cook, String slot) async {
    isLoading = true;
    notifyListeners();

    try {
      final subtotal = cart.fold<double>(0, (sum, item) => sum + (item.price * item.qty));
      
      if (selectedPayment.contains('Wallet')) {
        if (walletBalance >= subtotal) {
          walletBalance -= subtotal;
        } else {
          throw Exception("Insufficient Wallet Balance");
        }
      }

      final result = await _orderService.reserveSlot(
        cookId: cook.id.toString(),
        slotId: "evening_slot",
        quantity: 1,
      );

      if (result['success']) {
        await _orderService.logCommission(cook.id.toString(), subtotal);
        placeOrder(cook, slot);
      }
    } catch (e) {
      debugPrint("Order Error: $e");
      rethrow;
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

  void setPhone(String p) {
    phone = p;
    notifyListeners();
  }

  void updateDietaryPreferences({
    String? newDiet,
    double? newSpice,
    double? newBudget,
    List<String>? newAllergies,
    List<String>? newGoals,
    List<String>? newCuisines,
  }) {
    if (newDiet != null) diet = newDiet;
    if (newSpice != null) spiceLevel = newSpice;
    if (newBudget != null) budgetLevel = newBudget;
    if (newAllergies != null) allergies = newAllergies;
    if (newGoals != null) healthGoals = newGoals;
    if (newCuisines != null) cuisines = newCuisines;
    notifyListeners();
  }

  void updateProfile(String name, String p) {
    userName = name;
    phone = p;
    notifyListeners();
  }

  void setUserInfo(String name, String address) {
    userName = name;
    userAddress = address;
    int cookIdx = cooks.indexWhere((c) => c.id == 0);
    if (cookIdx != -1) {
      final old = cooks[cookIdx];
      cooks[cookIdx] = Cook(
        id: old.id,
        name: name,
        short: name.split(' ')[0],
        avatar: old.avatar,
        tagline: old.tagline,
        rating: old.rating,
        ratingCount: old.ratingCount,
        years: old.years,
        distance: old.distance,
        walkMin: old.walkMin,
        addr: address,
        c1: old.c1,
        c2: old.c2,
        fssai: old.fssai,
        inspected: old.inspected,
        top: old.top,
        cookOfMonth: old.cookOfMonth,
        veg: old.veg,
        cuisines: old.cuisines,
        menu: old.menu,
      );
    }
    if (address.isNotEmpty && !savedAddresses.contains(address)) {
      savedAddresses.insert(0, address);
    }
    notifyListeners();
  }

  void addDishToMenu(int cookId, Dish dish) {
    final cookIndex = cooks.indexWhere((c) => c.id == cookId);
    if (cookIndex >= 0) {
      cooks[cookIndex].menu.add(dish);
      notifyListeners();
    }
  }

  void removeDishFromMenu(int cookId, String dishId) {
    final cookIndex = cooks.indexWhere((c) => c.id == cookId);
    if (cookIndex >= 0) {
      cooks[cookIndex].menu.removeWhere((d) => d.id == dishId);
      notifyListeners();
    }
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

  void updateStatusPublic(int orderId, String status) {
    _updateOrderStatus(orderId, status);
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
  }

  void toggleAvailability() {
    isAvailable = !isAvailable;
    notifyListeners();
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
    orders = [
      Order(
        id: 9921,
        cookId: 0,
        cookName: 'Neha\'s Kitchen',
        cookShort: 'Neha',
        cookAvatar: '👩‍🍳',
        cookColors: [Colors.orange, Colors.red],
        cookDist: 0.4,
        cookWalk: 5,
        cookAddr: '123, Kitchen Street',
        items: [CartItem(cookId: 0, dishId: '1', name: 'Butter Chicken', emoji: '🍗', bg: '#FFE0B2', price: 320, qty: 2)],
        total: 640,
        status: 'placed',
        otp: '4422',
        slot: 'Lunch (12:30 PM)',
        placedAt: DateTime.now().subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
        customerName: 'Aarav Sharma',
      ),
      Order(
        id: 9922,
        cookId: 0,
        cookName: 'Neha\'s Kitchen',
        cookShort: 'Neha',
        cookAvatar: '👩‍🍳',
        cookColors: [Colors.orange, Colors.red],
        cookDist: 0.4,
        cookWalk: 5,
        cookAddr: '123, Kitchen Street',
        items: [CartItem(cookId: 0, dishId: '2', name: 'Paneer Tikka', emoji: '🧀', bg: '#E8F5E9', price: 280, qty: 1)],
        total: 280,
        status: 'preparing',
        otp: '1133',
        slot: 'Lunch (12:45 PM)',
        placedAt: DateTime.now().subtract(const Duration(minutes: 45)).millisecondsSinceEpoch,
        customerName: 'Ishani Roy',
      ),
      Order(
        id: 9923,
        cookId: 0,
        cookName: 'Neha\'s Kitchen',
        cookShort: 'Neha',
        cookAvatar: '👩‍🍳',
        cookColors: [Colors.orange, Colors.red],
        cookDist: 0.4,
        cookWalk: 5,
        cookAddr: '123, Kitchen Street',
        items: [CartItem(cookId: 0, dishId: '3', name: 'Dal Makhani', emoji: '🍲', bg: '#F3E5F5', price: 220, qty: 3)],
        total: 660,
        status: 'ready',
        otp: '7788',
        slot: 'Dinner (08:00 PM)',
        placedAt: DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        customerName: 'Vikram Singh',
      ),
      Order(
        id: 9915,
        cookId: 0,
        cookName: 'Neha\'s Kitchen',
        cookShort: 'Neha',
        cookAvatar: '👩‍🍳',
        cookColors: [Colors.orange, Colors.red],
        cookDist: 0.4,
        cookWalk: 5,
        cookAddr: '123, Kitchen Street',
        items: [CartItem(cookId: 0, dishId: '4', name: 'Mixed Veg', emoji: '🥗', bg: '#E1F5FE', price: 180, qty: 2)],
        total: 360,
        status: 'completed',
        otp: '9900',
        slot: 'Lunch (01:15 PM)',
        placedAt: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        customerName: 'Sanjana Malhotra',
      ),
    ];
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
