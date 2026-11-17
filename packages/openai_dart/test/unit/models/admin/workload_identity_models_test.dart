import 'package:openai_dart/openai_dart_admin.dart';
import 'package:test/test.dart';

void main() {
  test('provider updates preserve omitted, cleared and empty settings', () {
    final patch = UpdateWorkloadIdentityProviderRequest(
      description: null,
      attributeTransformations: const <WorkloadIdentityTransformation>[],
      enabled: false,
    );
    expect(patch.toJson(), {
      'description': null,
      'attribute_transformations': <Object>[],
      'enabled': false,
    });
    final decoded = UpdateWorkloadIdentityProviderRequest.fromJson(
      patch.toJson(),
    );
    expect(decoded.hasDescription, isTrue);
    expect(decoded, patch);
    expect(decoded.hashCode, patch.hashCode);
    expect(UpdateWorkloadIdentityProviderRequest().toJson(), isEmpty);
    expect(
      () =>
          UpdateWorkloadIdentityProviderRequest.fromJson(const {'name': null}),
      throwsFormatException,
    );
    expect(
      () => UpdateWorkloadIdentityProviderRequest(
        attributeTransformations: List.filled(
          21,
          const WorkloadIdentityTransformation(
            attribute: 'attribute',
            expression: 'assertion.subject',
          ),
        ),
      ),
      throwsFormatException,
    );
  });

  test('verification owns uploaded keys and emits required nullable URL', () {
    final fields = <String, dynamic>{'kid': 'fixture'};
    final keys = <String, dynamic>{
      'keys': [fields],
    };
    final uploaded =
        WorkloadIdentityVerification.uploadedJwks(keys)
            as WorkloadIdentityUploadedJwksVerification;
    fields.clear();
    keys.clear();
    expect(uploaded.jwks, {
      'keys': [
        {'kid': 'fixture'},
      ],
    });
    expect(uploaded.jwks.clear, throwsUnsupportedError);
    expect(WorkloadIdentityVerification.fromJson(uploaded.toJson()), uploaded);
    expect(uploaded.toString(), isNot(contains('fixture')));
    expect(const WorkloadIdentityVerification.discovery().toJson(), {
      'type': 'discovery',
      'discovery_url': null,
    });
    expect(
      () => WorkloadIdentityVerification.fromJson(const {'type': 'discovery'}),
      throwsFormatException,
    );
  });

  test('federation rule updates validate scalar matchers and write scopes', () {
    final matchers = <String, Object>{
      'subject': 'fixture-job',
      'runner': true,
      'run': 12,
      'score': 0.5,
    };
    final update = UpdateWorkloadIdentityFederationRuleRequest(
      name: null,
      attributeMatchers: matchers,
    );
    final json = update.toJson();
    matchers.clear();
    expect(json, {
      'name': null,
      'attribute_matchers': {
        'subject': 'fixture-job',
        'runner': true,
        'run': 12,
        'score': 0.5,
      },
    });
    expect(UpdateWorkloadIdentityFederationRuleRequest.fromJson(json), update);
    expect(update.attributeMatchers!.clear, throwsUnsupportedError);
    expect(
      () => UpdateWorkloadIdentityFederationRuleRequest(
        attributeMatchers: const {'bad': double.infinity},
      ),
      throwsFormatException,
    );
    final effective = WorkloadIdentityPermissions.fromJson(const {
      'type': 'restricted',
      'scopes': <String>[],
    });
    expect(effective.toJson(), {'type': 'restricted', 'scopes': <String>[]});
    expect(
      () => UpdateWorkloadIdentityFederationRuleRequest(permissions: effective),
      throwsFormatException,
    );
  });
}
