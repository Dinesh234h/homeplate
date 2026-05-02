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
  final String name;
  final String short;
  final String avatar;
  final String tagline;
  final double rating;
  final int ratingCount;
  final int years;
  final double distance;
  final int walkMin;
  final String addr;
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
