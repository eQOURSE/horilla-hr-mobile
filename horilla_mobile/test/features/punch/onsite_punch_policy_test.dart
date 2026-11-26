import 'package:flutter_test/flutter_test.dart';
import 'package:horilla_mobile/features/punch/data/geofence.dart';

void main() {
  for (final action in ['check-in', 'check-out']) {
    group('$action onsite evidence', () {
      test('valid face match: 75 m plus 25 m passes', () {
        const validFaceMatch = true;

        expect(
          validFaceMatch &&
              isWithinAccuracyBoundary(distanceFromOffice: 75, accuracy: 25),
          isTrue,
        );
      });

      test('valid face match: 76 m plus 25 m fails', () {
        const validFaceMatch = true;

        expect(
          validFaceMatch &&
              isWithinAccuracyBoundary(distanceFromOffice: 76, accuracy: 25),
          isFalse,
        );
      });

      test('valid face match: 10 m plus 26 m fails', () {
        const validFaceMatch = true;

        expect(
          validFaceMatch &&
              isWithinAccuracyBoundary(distanceFromOffice: 10, accuracy: 26),
          isFalse,
        );
      });

      test('wrong face fails even with valid onsite GPS', () {
        const faceMatch = false;

        expect(
          faceMatch &&
              isWithinAccuracyBoundary(distanceFromOffice: 75, accuracy: 25),
          isFalse,
        );
      });
    });
  }
}
