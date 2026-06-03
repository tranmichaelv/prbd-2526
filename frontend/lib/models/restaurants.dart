import 'dart:convert';
import 'package:prbd_2526_c03/services/api_client.dart';

class Restaurants {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String description;
  final double? rating;
  final int? priceRange;
  final int slotDuration;

  const Restaurants({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.description,
    this.rating,
    this.priceRange,
    required this.slotDuration,
  });

  factory Restaurants.fromJson(Map<String, dynamic> json) {
    return Restaurants(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      phone: json['phone'],
      description: json['description'],
      rating: json['rating'],
      priceRange: json['price_range'],
      slotDuration: json['slot_duration'],
    );
  }

}