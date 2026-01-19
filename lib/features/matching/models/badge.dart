import 'package:flutter/material.dart';

class Badge {
  final String name;
  final IconData icon;
  final String description;
  final int requiredMonths;
  final Color color;
  final bool isPremium;

  const Badge({
    required this.name,
    required this.icon,
    required this.description,
    required this.requiredMonths,
    required this.color,
    this.isPremium = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon.codePoint,
      'description': description,
      'requiredMonths': requiredMonths,
      'color': color.value,
      'isPremium': isPremium,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      name: (map['name'] ?? "").toString(),
      icon: IconData((map['icon'] ?? Icons.star.codePoint) as int,
          fontFamily: 'MaterialIcons'),
      description: (map['description'] ?? "").toString(),
      requiredMonths: (map['requiredMonths'] ?? 0) as int,
      color: Color((map['color'] ?? Colors.blue.value) as int),
      isPremium: (map['isPremium'] ?? true) as bool,
    );
  }

  static List<Badge> getBadgesForDuration(int monthsSubscribed) {
    return allBadges
        .where((badge) => monthsSubscribed >= badge.requiredMonths)
        .toList();
  }

  static const List<Badge> allBadges = [
    Badge(
      name: "New Premium",
      icon: Icons.star,
      description: "Welcome to Premium!",
      requiredMonths: 0,
      color: Colors.blue,
    ),
    Badge(
      name: "Premium Explorer",
      icon: Icons.star,
      description: "1 month of premium experience",
      requiredMonths: 1,
      color: Colors.green,
    ),
    Badge(
      name: "Premium Veteran",
      icon: Icons.star,
      description: "3 months of premium experience",
      requiredMonths: 3,
      color: Colors.amber,
    ),
    Badge(
      name: "Premium Elite",
      icon: Icons.star,
      description: "6 months of premium experience",
      requiredMonths: 6,
      color: Colors.purple,
    ),
    Badge(
      name: "Premium Legend",
      icon: Icons.star,
      description: "1 year of premium experience",
      requiredMonths: 12,
      color: Colors.red,
    ),
  ];
}
