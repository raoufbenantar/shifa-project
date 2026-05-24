class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'SHIFA_API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
}
