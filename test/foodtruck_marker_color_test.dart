import 'package:flutter_test/flutter_test.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';

void main() {
  test('marker color remains tied to the foodtruck owner', () {
    const firstTruck = FoodTruck(
      id: 'truck-a',
      ownerId: 'owner-123',
      name: 'First truck',
      latitude: 0,
      longitude: 0,
    );
    const secondTruck = FoodTruck(
      id: 'truck-b',
      ownerId: 'owner-123',
      name: 'Second truck',
      latitude: 0,
      longitude: 0,
    );

    expect(firstTruck.markerColor, secondTruck.markerColor);
  });

  test('marker color remains stable for foodtrucks without an owner ID', () {
    const firstTruck = FoodTruck(
      id: 'legacy-truck',
      name: 'Legacy truck',
      latitude: 0,
      longitude: 0,
    );
    const secondTruck = FoodTruck(
      id: 'legacy-truck',
      name: 'Legacy truck',
      latitude: 0,
      longitude: 0,
    );

    expect(firstTruck.markerColor, secondTruck.markerColor);
  });
}
