import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ApiKeyProvider', () {
    test('creates with API key', () {
      const provider = ApiKeyProvider('sk-test-key');
      expect(provider.apiKey, 'sk-test-key');
    });

    test('getHeaders returns Bearer token', () {
      const provider = ApiKeyProvider('sk-test-key');
      final headers = provider.getHeaders();

      expect(headers, {'Authorization': 'Bearer sk-test-key'});
    });
  });

  group('OrganizationApiKeyProvider', () {
    test('creates with API key and organization', () {
      const provider = OrganizationApiKeyProvider(
        apiKey: 'sk-test-key',
        organization: 'org-123',
      );

      expect(provider.apiKey, 'sk-test-key');
      expect(provider.organization, 'org-123');
      expect(provider.project, isNull);
    });

    test('creates with API key, organization, and project', () {
      const provider = OrganizationApiKeyProvider(
        apiKey: 'sk-test-key',
        organization: 'org-123',
        project: 'proj-456',
      );

      expect(provider.apiKey, 'sk-test-key');
      expect(provider.organization, 'org-123');
      expect(provider.project, 'proj-456');
    });

    test('getHeaders returns auth and organization headers', () {
      const provider = OrganizationApiKeyProvider(
        apiKey: 'sk-test-key',
        organization: 'org-123',
      );

      final headers = provider.getHeaders();

      expect(headers, {
        'Authorization': 'Bearer sk-test-key',
        'OpenAI-Organization': 'org-123',
      });
    });

    test('getHeaders includes project header when set', () {
      const provider = OrganizationApiKeyProvider(
        apiKey: 'sk-test-key',
        organization: 'org-123',
        project: 'proj-456',
      );

      final headers = provider.getHeaders();

      expect(headers, {
        'Authorization': 'Bearer sk-test-key',
        'OpenAI-Organization': 'org-123',
        'OpenAI-Project': 'proj-456',
      });
    });
  });

  group('AzureApiKeyProvider', () {
    test('creates with API key', () {
      const provider = AzureApiKeyProvider('azure-key');
      expect(provider.apiKey, 'azure-key');
    });

    test('getHeaders returns api-key header', () {
      const provider = AzureApiKeyProvider('azure-key');
      final headers = provider.getHeaders();

      expect(headers, {'api-key': 'azure-key'});
    });
  });
}
