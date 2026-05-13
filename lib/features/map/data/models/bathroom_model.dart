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

  factory BathroomModel.fromMap(Map<String, dynamic> map) {
    final latitude =
        (map['latitude'] as num?)?.toDouble() ??
        (map['lat'] as num?)?.toDouble() ??
        0.0;
    final longitude =
        (map['longitude'] as num?)?.toDouble() ??
        (map['lng'] as num?)?.toDouble() ??
        0.0;
    final isAccessible = (map['is_accessible'] as bool?) ?? false;

    return BathroomModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? 'Sem nome',
      location: LatLng(latitude, longitude),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      tags:
          (map['tags'] as List?)?.map((e) => e.toString()).toList() ??
          [if (isAccessible) 'Acessivel'],
      isOpen: (map['open'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'lat': location.latitude,
      'lng': location.longitude,
      'rating': rating,
      'tags': tags,
      'is_accessible': tags.contains('Acessivel'),
      'open': isOpen,
    };
  }
}
