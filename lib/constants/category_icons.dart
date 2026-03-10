import 'package:flutter/material.dart';

class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> icons = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'movie': Icons.movie,
    'medical_services': Icons.medical_services,
    'payments': Icons.payments,
    'trending_up': Icons.trending_up,
    'shopping_cart': Icons.shopping_cart,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'hotel': Icons.hotel,
    'electric_bolt': Icons.electric_bolt,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,
    'phone_android': Icons.phone_android,
    'local_gas_station': Icons.local_gas_station,
    'card_giftcard': Icons.card_giftcard,
    'pets': Icons.pets,
    'celebration': Icons.celebration,
    'spa': Icons.spa,
    'sports_esports': Icons.sports_esports,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,
    'monetization_on': Icons.monetization_on,
    'receipt_long': Icons.receipt_long,
    'category': Icons.category,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'person': Icons.person,
    'groups': Icons.groups,
    'coffee': Icons.coffee,
    'fastfood': Icons.fastfood,
    'icecream': Icons.icecream,
    'liquor': Icons.liquor,
    'checkroom': Icons.checkroom,
    'directions_bus': Icons.directions_bus,
    'directions_bike': Icons.directions_bike,
    'airplanemode_active': Icons.airplanemode_active,
    'computer': Icons.computer,
    'build': Icons.build,
    'brush': Icons.brush,
    'camera_alt': Icons.camera_alt,
    'music_note': Icons.music_note,
    'sports_soccer': Icons.sports_soccer,
    'self_improvement': Icons.self_improvement,
  };

  static IconData getIcon(String name) {
    return icons[name] ?? Icons.category;
  }
}
