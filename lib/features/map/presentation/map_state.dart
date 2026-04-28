part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final List<Bathroom> bathrooms;
  final LatLng? currentPosition;
  final Bathroom? selectedBathroom;
  final Bathroom? nearestBathroom;

  const MapLoaded({
    required this.bathrooms,
    this.currentPosition,
    this.selectedBathroom,
    this.nearestBathroom,
  });

  MapLoaded copyWith({
    List<Bathroom>? bathrooms,
    LatLng? currentPosition,
    Bathroom? selectedBathroom,
    Bathroom? nearestBathroom,
    bool clearSelection = false,
    bool clearNearest = false,
  }) {
    return MapLoaded(
      bathrooms: bathrooms ?? this.bathrooms,
      currentPosition: currentPosition ?? this.currentPosition,
      selectedBathroom: clearSelection ? null : (selectedBathroom ?? this.selectedBathroom),
      nearestBathroom: clearNearest ? null : (nearestBathroom ?? this.nearestBathroom),
    );
  }

  @override
  List<Object?> get props => [bathrooms, currentPosition, selectedBathroom, nearestBathroom];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
