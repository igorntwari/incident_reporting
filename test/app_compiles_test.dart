import 'package:flutter_test/flutter_test.dart';
import 'package:incident_reporting/app.dart';

// Importing the root widget forces every screen, provider and route to
// compile, catching broken imports or types across the whole app.
void main() {
  test('app widget tree compiles', () {
    expect(const CampusFixApp(), isNotNull);
  });
}
