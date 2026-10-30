/// App-wide business constants. Change a rule here and it changes everywhere.
abstract final class AppConfig {
  static const appName = 'Campus Fix';

  /// Only verified accounts on these domains may use the app.
  /// Mirrored server-side in `firestore.rules` and `storage.rules`.
  static const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

  static const minPasswordLength = 8;
  static const titleMaxLength = 80;
  static const descriptionMinLength = 15;
  static const descriptionMaxLength = 1000;

  /// Photos are resized and compressed on-device before upload.
  static const photoMaxDimension = 1600.0;
  static const photoQuality = 75;

  static const recentReportsLimit = 3;

  /// Common campus locations offered as suggestions in the report form.
  static const campusLocations = [
    'Block A',
    'Block B',
    'Block C',
    'Library',
    'Cafeteria',
    'Student Residence',
    'Sports Ground',
    'Main Hall',
    'Parking Lot',
    'Administration Office',
  ];
}

/// Firestore collection and Storage folder names.
abstract final class FirebasePaths {
  static const users = 'users';
  static const incidents = 'incidents';
  static const incidentPhotos = 'incident_photos';
}
