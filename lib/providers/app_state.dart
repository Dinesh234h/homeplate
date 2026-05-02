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
  
  // Advanced State for "Working Buttons"
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

  void updateProfile(String name, String p) {
    userName = name;
    phone = p;
    notifyListeners();
  }

  void setUserInfo(String name, String address) {
    userName = name;
    userAddress = address;
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

  void updateDishInMenu(int cookId, String dishId, Dish updatedDish) {
    final cookIndex = cooks.indexWhere((c) => c.id == cookId);
    if (cookIndex >= 0) {
      final dishIndex = cooks[cookIndex].menu.indexWhere((d) => d.id == dishId);
      if (dishIndex >= 0) {
        cooks[cookIndex].menu[dishIndex] = updatedDish;
        notifyListeners();
      }
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
          Dish(
            id: "d2_2",
            name: "Aloo Paratha (2 pcs)",
            desc: "Spiced potato stuffed flatbread with curd and pickle",
            emoji: "🥙",
            price: 90,
            rating: 4.8,
            orders: 450,
            veg: true,
            bg: "#FFF9C4",
            hbg: "linear-gradient(135deg, #FF6B47, #F4B942)",
            ingredients: "Wheat flour, Potato, Spices",
            allergens: ["Gluten"],
            nutri: [Nutrient("Cal", "310"), Nutrient("Prot", "8g"), Nutrient("Carb", "45g")],
          ),
          Dish(
            id: "d2_3",
            name: "Kadai Paneer",
            desc: "Paneer cubes cooked with bell peppers and freshly ground spices",
            emoji: "🍲",
            price: 180,
            rating: 4.6,
            orders: 320,
            veg: true,
            bg: "#FFCCBC",
            hbg: "linear-gradient(135deg, #FF6B47, #F4B942)",
            ingredients: "Paneer, Capsicum, Tomato, Spices",
            allergens: ["Dairy"],
            nutri: [Nutrient("Cal", "340"), Nutrient("Prot", "16g"), Nutrient("Carb", "12g")],
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
          Dish(
            id: "d4",
            name: "Set Dosa (3 pcs)",
            desc: "Soft and fluffy Dosas served with Saagu and Chutney",
            emoji: "🥞",
            price: 80,
            rating: 4.8,
            orders: 950,
            veg: true,
            bg: "#FFF9C4",
            hbg: "linear-gradient(135deg, #2D5F3F, #5DAA75)",
            ingredients: "Rice, Urad Dal, Spices",
            allergens: [],
            nutri: [Nutrient("Cal", "280"), Nutrient("Prot", "6g"), Nutrient("Carb", "48g")],
          ),
          Dish(
            id: "d5",
            name: "Ragi Mudde Thali",
            desc: "Finger millet ball served with Soppu Saaru and Bassaru",
            emoji: "🥣",
            price: 130,
            rating: 4.9,
            orders: 540,
            veg: true,
            bg: "#D7CCC8",
            hbg: "linear-gradient(135deg, #2D5F3F, #5DAA75)",
            ingredients: "Ragi, Greens, Lentils, Spices",
            allergens: [],
            nutri: [Nutrient("Cal", "410"), Nutrient("Prot", "10g"), Nutrient("Carb", "72g")],
          ),
        ],
      ),
    ];
  }
}
