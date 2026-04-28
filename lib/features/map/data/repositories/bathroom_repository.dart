import 'package:latlong2/latlong.dart';
import 'package:viva_livre_app/features/map/data/models/bathroom_model.dart';
import 'package:viva_livre_app/features/map/domain/entities/bathroom.dart';

class BathroomRepository {
  // Base de dados local (futuramente será Firestore)
  static const List<Map<String, dynamic>> _kBathroomsDb = [
    {
      'id': 1,
      'name': 'Minha Casa',
      'lat': -23.66070438587852,
      'lng': -46.43089117960558,
      'rating': 5.0,
      'tags': ['Privado', 'Acessível'],
      'open': true,
    },
    {
      'id': 2,
      'name': 'Nagumo',
      'lat': -23.665294452821598,
      'lng': -46.43228530883789,
      'rating': 4.5,
      'tags': ['Público', 'Limpo'],
      'open': true,
    },
    {
      'id': 3,
      'name': 'Shopping Metrô Tatuapé',
      'lat': -23.541389,
      'lng': -46.575833,
      'rating': 4.8,
      'tags': ['Shopping', 'Acessível', 'Limpo'],
      'open': true,
    },
    {
      'id': 4,
      'name': 'Parque Ibirapuera',
      'lat': -23.587416,
      'lng': -46.657634,
      'rating': 3.5,
      'tags': ['Público', 'Parque'],
      'open': true,
    },
    {
      'id': 5,
      'name': 'Estação da Luz',
      'lat': -23.534722,
      'lng': -46.635833,
      'rating': 3.0,
      'tags': ['Público', 'Estação'],
      'open': true,
    },
  ];

  final Distance _distance = const Distance();

  /// Retorna todos os banheiros disponíveis
  Future<List<Bathroom>> fetchBathrooms() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _kBathroomsDb
        .map((json) => BathroomModel.fromJson(json))
        .toList();
  }

  /// Encontra o banheiro mais próximo da posição atual
  Bathroom? findNearestBathroom(LatLng currentPosition, List<Bathroom> bathrooms) {
    if (bathrooms.isEmpty) return null;

    Bathroom? nearest;
    double nearestDistance = double.infinity;

    for (final bathroom in bathrooms) {
      final distance = _distance.as(
        LengthUnit.Meter,
        currentPosition,
        bathroom.location,
      );

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = bathroom;
      }
    }

    return nearest;
  }

  /// Calcula a distância entre dois pontos em metros
  double calculateDistance(LatLng from, LatLng to) {
    return _distance.as(LengthUnit.Meter, from, to);
  }
}
