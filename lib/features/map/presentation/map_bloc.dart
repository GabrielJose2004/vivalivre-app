import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:viva_livre_app/features/map/data/repositories/bathroom_repository.dart';
import 'package:viva_livre_app/features/map/domain/entities/bathroom.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final BathroomRepository _repository;

  MapBloc({required BathroomRepository repository})
      : _repository = repository,
        super(const MapInitial()) {
    on<MapLoadBathrooms>(_onLoadBathrooms);
    on<MapUpdateCurrentPosition>(_onUpdateCurrentPosition);
    on<MapFindNearestBathroom>(_onFindNearestBathroom);
    on<MapSelectBathroom>(_onSelectBathroom);
    on<MapClearSelection>(_onClearSelection);
  }

  Future<void> _onLoadBathrooms(
    MapLoadBathrooms event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    try {
      final bathrooms = await _repository.fetchBathrooms();
      emit(MapLoaded(bathrooms: bathrooms));
    } catch (e) {
      emit(MapError('Erro ao carregar banheiros: $e'));
    }
  }

  void _onUpdateCurrentPosition(
    MapUpdateCurrentPosition event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(currentPosition: event.position));
    }
  }

  void _onFindNearestBathroom(
    MapFindNearestBathroom event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      
      if (currentState.currentPosition == null) {
        emit(const MapError('Localização atual não disponível'));
        return;
      }

      final nearest = _repository.findNearestBathroom(
        currentState.currentPosition!,
        currentState.bathrooms,
      );

      if (nearest != null) {
        emit(currentState.copyWith(
          nearestBathroom: nearest,
          selectedBathroom: nearest,
        ));
      } else {
        emit(const MapError('Nenhum banheiro encontrado'));
      }
    }
  }

  void _onSelectBathroom(
    MapSelectBathroom event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(selectedBathroom: event.bathroom));
    }
  }

  void _onClearSelection(
    MapClearSelection event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(clearSelection: true, clearNearest: true));
    }
  }
}
