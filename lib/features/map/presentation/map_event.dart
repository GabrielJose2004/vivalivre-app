part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapLoadBathrooms extends MapEvent {
  const MapLoadBathrooms();
}

class MapUpdateCurrentPosition extends MapEvent {
  final LatLng position;

  const MapUpdateCurrentPosition(this.position);

  @override
  List<Object?> get props => [position];
}

class MapFindNearestBathroom extends MapEvent {
  const MapFindNearestBathroom();
}

class MapSelectBathroom extends MapEvent {
  final Bathroom? bathroom;

  const MapSelectBathroom(this.bathroom);

  @override
  List<Object?> get props => [bathroom];
}

class MapClearSelection extends MapEvent {
  const MapClearSelection();
}
