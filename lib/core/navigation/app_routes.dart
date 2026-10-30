/// Every route path in the app, defined once.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';

  static const home = '/';
  static const reports = '/reports';
  static const profile = '/profile';
  static const newReport = '/report';

  static String incidentDetails(String id) => '/incidents/$id';
  static String editIncident(String id) => '/incidents/$id/edit';

  /// Routes reachable without a session.
  static const public = {login, register};
}
