import 'package:flutter_test/flutter_test.dart';
import 'package:viva_livre_app/features/map/data/models/bathroom_model.dart';

void main() {
  group('BathroomModel.fromMap', () {
    test('parses latitude and longitude from backend payload', () {
      final model = BathroomModel.fromMap({
        'id': 26,
        'name': 'Banheiro Teste Maua',
        'latitude': -23.6607,
        'longitude': -46.4309,
        'is_accessible': true,
      });

      expect(model.id, 26);
      expect(model.name, 'Banheiro Teste Maua');
      expect(model.location.latitude, -23.6607);
      expect(model.location.longitude, -46.4309);
      expect(model.tags, contains('Acessivel'));
    });

    test('keeps compatibility with legacy lat/lng payload', () {
      final model = BathroomModel.fromMap({
        'id': 1,
        'name': 'Legacy Bathroom',
        'lat': -23.5,
        'lng': -46.6,
        'tags': ['24h'],
      });

      expect(model.location.latitude, -23.5);
      expect(model.location.longitude, -46.6);
      expect(model.tags, contains('24h'));
    });

    test('falls back safely when coordinates are missing', () {
      final model = BathroomModel.fromMap({
        'id': 2,
        'name': 'No Coordinates',
      });

      expect(model.location.latitude, 0.0);
      expect(model.location.longitude, 0.0);
      expect(model.tags, isEmpty);
    });
  });
}
