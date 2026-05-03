import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/order_service.dart';

class AppState extends ChangeNotifier {
  // Services
  final OrderService _orderService = OrderService();

  List<UserRole> roles = [UserRole.consumer];
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

  // Preferences (AI Meal Planner)
  List<String> allergies = [];
  List<String> healthGoals = [];
  List<String> cuisines = [];
  String diet = 'veg';
  double spiceLevel = 50.0;
  double budgetLevel = 40.0;

  // AI Meal Planner Result
  Map<String, dynamic>? aiSuggestion;

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

  void setUserInfo(String name, String address) {
    userName = name;
    userAddress = address;
    int cookIdx = cooks.indexWhere((c) => c.id == 0);
    if (cookIdx != -1) {
      cooks[cookIdx].name = name;
      cooks[cookIdx].addr = address;
    }
    if (address.isNotEmpty && !savedAddresses.contains(address)) {
      savedAddresses.insert(0, address);
    }
    notifyListeners();
  }

  void setFirebaseUser(User? user) {
    firebaseUser = user;
    notifyListeners();
  }

  void setPhone(String p) {
    phone = p;
    notifyListeners();
  }

  void updateProfile(String name, String p) {
    userName = name;
    phone = p;
    notifyListeners();
  }

  void addAddress(String address) {
    if (address.isNotEmpty && !savedAddresses.contains(address)) {
      savedAddresses.add(address);
      notifyListeners();
    }
  }

  void updateAddress(int index, String address) {
    if (index >= 0 && index < savedAddresses.length && address.isNotEmpty) {
      savedAddresses[index] = address;
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    selectedPayment = method;
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

  void setAiSuggestion(Map<String, dynamic> suggestion) {
    aiSuggestion = suggestion;
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
  }

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

  void updateStatusPublic(int orderId, String status) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      orders[index].status = status;
      if (currentOrder?.id == orderId) currentOrder = orders[index];
      notifyListeners();
    }
  }

  void toggleAvailability() {
    isAvailable = !isAvailable;
    notifyListeners();
  }

  void addDishToMenu(int cookId, Dish dish) {
    final index = cooks.indexWhere((c) => c.id == cookId);
    if (index >= 0) {
      cooks[index].menu.add(dish);
      notifyListeners();
    }
  }

  void removeDishFromMenu(int cookId, String dishId) {
    final index = cooks.indexWhere((c) => c.id == cookId);
    if (index >= 0) {
      cooks[index].menu.removeWhere((d) => d.id == dishId);
      notifyListeners();
    }
  }

  void toggleLike(String postId) {
    if (likedPosts.contains(postId)) {
      likedPosts.remove(postId);
    } else {
      likedPosts.add(postId);
    }
    notifyListeners();
  }

  void subscribeToPlan(String planName) {
    activePlanName = planName;
    planDueDate = DateTime.now().add(const Duration(days: 30));
    notifyListeners();
  }

  void _initMockData() {
    orders = [
      Order(
        id: 9916,
        cookId: 0,
        cookName: 'Neha\'s Kitchen',
        cookShort: 'Neha',
        cookAvatar: '👩‍🍳',
        cookColors: [Colors.orange, Colors.red],
        cookDist: 0.4,
        cookWalk: 5,
        cookAddr: '123, Kitchen Street',
        items: [CartItem(cookId: 0, dishId: 'd1', name: 'Butter Chicken', emoji: '🍗', bg: '#FFE0B2', price: 320, qty: 1)],
        total: 320,
        status: 'placed',
        otp: '4321',
        slot: 'Lunch (Today)',
        placedAt: DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
        customerName: 'Avi Nash',
      ),
    ];
    cooks = [
      Cook(
        id: 0,
        name: "Neha's Kitchen",
        short: "Neha",
        avatar: "👩‍🍳",
        tagline: "Authentic North Indian meals",
        rating: 4.8,
        ratingCount: 124,
        years: 5,
        distance: 0.4,
        walkMin: 5,
        addr: "123, Kitchen Street, Bellandur",
        c1: Colors.orange,
        c2: Colors.red,
        fssai: true,
        inspected: true,
        top: true,
        cookOfMonth: false,
        veg: false,
        cuisines: ["North Indian", "Punjabi"],
        menu: [
          Dish(
            id: "d1",
            name: "Butter Chicken + Garlic Naan",
            desc: "Rich creamy tomato gravy with tender chicken",
            emoji: "🍗",
            price: 320,
            rating: 4.9,
            orders: 850,
            veg: false,
            bg: "#FFE0B2",
            hbg: "linear-gradient(135deg, #FF9966, #FF5E62)",
            ingredients: "Chicken, Butter, Cream, Spices",
            allergens: ["Dairy"],
            nutri: [Nutrient("Cal", "450"), Nutrient("Prot", "24g"), Nutrient("Carb", "30g")],
          ),
          Dish(
            id: "d2",
            name: "Paneer Tikka Platter",
            desc: "Spiced cottage cheese cubes grilled to perfection",
            emoji: "🧀",
            price: 280,
            rating: 4.7,
            orders: 420,
            veg: true,
            bg: "#E8F5E9",
            hbg: "linear-gradient(135deg, #11998e, #38ef7d)",
            ingredients: "Paneer, Curd, Bell Peppers, Spices",
            allergens: ["Dairy"],
            nutri: [Nutrient("Cal", "320"), Nutrient("Prot", "18g"), Nutrient("Carb", "12g")],
          ),
        ],
      ),
      Cook(
        id: 1,
        name: "Priya's Traditional",
        short: "Priya",
        avatar: "👩",
        tagline: "South Indian delicacies",
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
            desc: "Hot lentil rice with mixed vegetables",
            emoji: "🍚",
            price: 90,
            rating: 4.9,
            orders: 1200,
            veg: true,
            bg: "#E3F0E8",
            hbg: "linear-gradient(135deg, #2D5F3F, #5DAA75)",
            ingredients: "Rice, Lentils, Vegetables, Spices",
            allergens: [],
            nutri: [Nutrient("Cal", "350"), Nutrient("Prot", "12g"), Nutrient("Carb", "58g")],
          ),
        ],
      ),
    ];
  }

  String tr(String key) {
    Map<String, String> en = {
      'nearby_cooks': 'Nearby Cooks',
      'kitchens_found': 'kitchens found',
      'active_orders': 'Active Orders',
      'upcoming_orders': 'Upcoming',
      'past_orders': 'Past',
      'impact_title': 'Impact Created',
      'meal_planner': 'AI MEAL PLANNER',
      'delivering_to': 'DELIVERING TO',
      'logout': 'LOGOUT',
      'switch_cook': 'Switch to Cook Mode',
      'switch_user': 'Switch to User Mode',
      'online_status': 'ONLINE STATUS',
      'orders_summary': 'ORDERS SUMMARY',
      'payout_history': 'Payout History',
      'accept': 'Accept',
      'cook': 'Cook',
      'ready': 'Ready',
      'complete': 'Complete',
    };
    return en[key] ?? key;
  }
}
