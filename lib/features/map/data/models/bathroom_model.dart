import 'package:latlong2/latlong.dart';
import 'package:viva_livre_app/features/map/domain/entities/bathroom.dart';

class BathroomModel extends Bathroom {
  const BathroomModel({
    required super.id,
    required super.name,
    required super.location,
    required super.rating,
    required super.tags,
    required super.isOpen,
  });

  factory BathroomModel.fromJson(Map<String, dynamic> json) {
    return BathroomModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: LatLng(
        json['lat'] as double,
        json['lng'] as double,
      ),
      rating: (json['rating'] as num).toDouble(),
      tags: List<String>.from(json['tags'] as List),
      isOpen: json['open'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': location.latitude,
      'lng': location.longitude,
      'rating': rating,
      'tags': tags,
      'open': isOpen,
    };
  }
}
