import 'package:flutter/material.dart';

enum UserRole { consumer, cook }

class Dish {
  final String id;
  final String name;
  final String desc;
  final String emoji;
  final double price;
  final double rating;
  final int orders;
  final bool veg;
  final String bg;
  final String hbg;
  final String ingredients;
  final List<String> allergens;
  final List<Nutrient> nutri;

  Dish({
    required this.id,
    required this.name,
    required this.desc,
    required this.emoji,
    required this.price,
    required this.rating,
    required this.orders,
    required this.veg,
    required this.bg,
    required this.hbg,
    required this.ingredients,
    required this.allergens,
    required this.nutri,
  });
}

class Nutrient {
  final String l;
  final String v;
  Nutrient(this.l, this.v);
}

class Cook {
  final int id;
  late String name;
  final String short;
  final String avatar;
  final String tagline;
  final double rating;
  final int ratingCount;
  final int years;
  final double distance;
  final int walkMin;
  late String addr;
  final Color c1;
  final Color c2;
  final bool fssai;
  final bool inspected;
  final bool top;
  final bool cookOfMonth;
  final bool veg;
  final List<String> cuisines;
  final List<Dish> menu;

  Cook({
    required this.id,
    required this.name,
    required this.short,
    required this.avatar,
    required this.tagline,
    required this.rating,
    required this.ratingCount,
    required this.years,
    required this.distance,
    required this.walkMin,
    required this.addr,
    required this.c1,
    required this.c2,
    required this.fssai,
    required this.inspected,
    required this.top,
    required this.cookOfMonth,
    required this.veg,
    required this.cuisines,
    required this.menu,
  });
}

class CartItem {
  final int cookId;
  final String dishId;
  final String name;
  final String emoji;
  final String bg;
  final double price;
  int qty;

  CartItem({
    required this.cookId,
    required this.dishId,
    required this.name,
    required this.emoji,
    required this.bg,
    required this.price,
    required this.qty,
  });
}

class Order {
  final int id;
  final int cookId;
  final String cookName;
  final String cookShort;
  final String cookAvatar;
  final List<Color> cookColors;
  final double cookDist;
  final int cookWalk;
  final String cookAddr;
  final List<CartItem> items;
  final double total;
  final String otp;
  final String slot;
  String status;
  final int placedAt;
  int? ratedStars;
  final String customerName;

  Order({
    required this.id,
    required this.cookId,
    required this.cookName,
    required this.cookShort,
    required this.cookAvatar,
    required this.cookColors,
    required this.cookDist,
    required this.cookWalk,
    required this.cookAddr,
    required this.items,
    required this.total,
    required this.otp,
    required this.slot,
    required this.status,
    required this.placedAt,
    this.ratedStars,
    required this.customerName,
  });
}

class SelectionState {
  final String id;
  final bool isSelected;

  SelectionState({
    required this.id,
    required this.isSelected,
  });

  factory SelectionState.fromMap(Map<String, dynamic> map) {
    return SelectionState(
      id: map['id'] ?? '',
      isSelected: map['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_selected': isSelected,
    };
  }

  SelectionState copyWith({
    String? id,
    bool? isSelected,
  }) {
    return SelectionState(
      id: id ?? this.id,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectionState &&
      other.id == id &&
      other.isSelected == isSelected;
  }

  @override
  int get hashCode => id.hashCode ^ isSelected.hashCode;
}

class CategoryState {
  final int id;
  final bool isSelected;

  CategoryState({
    required this.id,
    required this.isSelected,
  });

  factory CategoryState.fromMap(Map<String, dynamic> map) {
    return CategoryState(
      id: map['id'] ?? 0,
      isSelected: map['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_selected': isSelected,
    };
  }

  CategoryState copyWith({
    int? id,
    bool? isSelected,
  }) {
    return CategoryState(
      id: id ?? this.id,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryState &&
      other.id == id &&
      other.isSelected == isSelected;
  }

  @override
  int get hashCode => id.hashCode ^ isSelected.hashCode;
}

class LanguageSelection {
  final String language;
  final String languageCode;

  LanguageSelection({
    required this.language,
    required this.languageCode,
  });

  factory LanguageSelection.fromMap(Map<String, dynamic> map) {
    return LanguageSelection(
      language: map['language'] ?? 'English',
      languageCode: map['language_code'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'language_code': languageCode,
    };
  }

  LanguageSelection copyWith({
    String? language,
    String? languageCode,
  }) {
    return LanguageSelection(
      language: language ?? this.language,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LanguageSelection &&
      other.language == language &&
      other.languageCode == languageCode;
  }

  @override
  int get hashCode => language.hashCode ^ languageCode.hashCode;
}

class DietaryPreferences {
  final List<SelectionState> dietTypes;
  final List<SelectionState> cuisines;
  final List<SelectionState> spiceLevels;
  final List<SelectionState> budgets;
  final List<SelectionState> allergies;
  final List<SelectionState> healthGoals;

  DietaryPreferences({
    required this.dietTypes,
    required this.cuisines,
    required this.spiceLevels,
    required this.budgets,
    required this.allergies,
    required this.healthGoals,
  });

  factory DietaryPreferences.fromMap(Map<String, dynamic> map) {
    return DietaryPreferences(
      dietTypes: (map['diet_types'] as List?)?.map((x) => SelectionState.fromMap(x)).toList() ?? [],
      cuisines: (map['cuisines'] as List?)?.map((x) => SelectionState.fromMap(x)).toList() ?? [],
      spiceLevels: (map['spice_levels'] as List?)?.map((x) => SelectionState.fromMap(x)).toList() ?? [],
      budgets: (map['budgets'] as List?)?.map((x) => SelectionState.fromMap(x)).toList() ?? [],
      allergies: (map['allergies'] as List?)?.map((x) => SelectionState.fromMap(x)).toList() ?? [],
      healthGoals: (map['health_goals'] as List?)?.map((x) => SelectionState.fromMap(x)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diet_types': dietTypes.map((x) => x.toMap()).toList(),
      'cuisines': cuisines.map((x) => x.toMap()).toList(),
      'spice_levels': spiceLevels.map((x) => x.toMap()).toList(),
      'budgets': budgets.map((x) => x.toMap()).toList(),
      'allergies': allergies.map((x) => x.toMap()).toList(),
      'health_goals': healthGoals.map((x) => x.toMap()).toList(),
    };
  }

  DietaryPreferences copyWith({
    List<SelectionState>? dietTypes,
    List<SelectionState>? cuisines,
    List<SelectionState>? spiceLevels,
    List<SelectionState>? budgets,
    List<SelectionState>? allergies,
    List<SelectionState>? healthGoals,
  }) {
    return DietaryPreferences(
      dietTypes: dietTypes ?? this.dietTypes,
      cuisines: cuisines ?? this.cuisines,
      spiceLevels: spiceLevels ?? this.spiceLevels,
      budgets: budgets ?? this.budgets,
      allergies: allergies ?? this.allergies,
      healthGoals: healthGoals ?? this.healthGoals,
    );
  }
}
