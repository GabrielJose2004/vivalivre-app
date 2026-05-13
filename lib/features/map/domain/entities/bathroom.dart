import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Bathroom extends Equatable {
  final int id;
  final String name;
  final LatLng location;
  final double rating;
  final List<String> tags;
  final bool isOpen;
  final String? address;
  final bool isAccessible;
  final bool hasChangingTable;
  final bool isFree;
  final double cleanlinessRating;
  final double accessibilityRating;
  final String? photoUrl;

  const Bathroom({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.tags,
    required this.isOpen,
    this.address,
    this.isAccessible = false,
    this.hasChangingTable = false,
    this.isFree = false,
    this.cleanlinessRating = 0.0,
    this.accessibilityRating = 0.0,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    rating,
    tags,
    isOpen,
    address,
    isAccessible,
    hasChangingTable,
    isFree,
    cleanlinessRating,
    accessibilityRating,
    photoUrl,
  ];
}
