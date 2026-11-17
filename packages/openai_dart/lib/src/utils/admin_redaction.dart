import 'package:http/http.dart' as http;

/// Recognizes the organization operations routed through the Admin client.
bool isAdminRequest(http.BaseRequest? request) {
  if (request == null) return false;
  final s = request.url.pathSegments;
  bool suffix(List<String?> pattern) {
    if (s.length < pattern.length) return false;
    for (var i = 0; i < pattern.length; i++) {
      if (pattern[i] != null &&
          s[s.length - pattern.length + i] != pattern[i]) {
        return false;
      }
    }
    return true;
  }

  if (suffix(['organization', 'external_keys']) ||
      suffix(['organization', 'external_storage'])) {
    return const {'GET', 'POST'}.contains(request.method);
  }
  if (suffix(['organization', 'external_keys', null]) ||
      suffix(['organization', 'external_storage', null])) {
    return const {'GET', 'DELETE'}.contains(request.method);
  }
  if (suffix(['organization', 'external_keys', null, 'validate']) ||
      suffix(['organization', 'external_storage', null, 'validate'])) {
    return request.method == 'POST';
  }
  if (suffix(['organization', 'projects', null, 'service_tier_settings'])) {
    return const {'GET', 'POST'}.contains(request.method);
  }
  return (request.method == 'POST' &&
          suffix(['organization', 'projects', null, 'api_keys', null])) ||
      (request.method == 'GET' &&
          suffix(['organization', 'usage', 'decisions']));
}
