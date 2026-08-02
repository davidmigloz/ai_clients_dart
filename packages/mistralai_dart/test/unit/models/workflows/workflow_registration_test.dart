// ignore_for_file: deprecated_member_use_from_same_package
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowRegistration', () {
    Map<String, dynamic> registrationJson() => {
      'id': 'reg-1',
      'deployment_id': 'deployment-id-1',
      'deployment_name': 'deployment-name-1',
      'definition': {
        'input_schema': <String, dynamic>{},
        'enforce_determinism': false,
        'on_behalf_of': false,
      },
      'workflow_id': 'workflow-1',
      'compatible_with_chat_assistant': true,
    };

    test('fromJson parses all fields', () {
      final registration = WorkflowRegistration.fromJson(registrationJson());

      expect(registration.id, 'reg-1');
      expect(registration.deploymentId, 'deployment-id-1');
      expect(registration.deploymentName, 'deployment-name-1');
      expect(registration.workflowId, 'workflow-1');
      expect(registration.compatibleWithChatAssistant, isTrue);
    });

    test('toJson round-trips', () {
      final registration = WorkflowRegistration.fromJson(registrationJson());

      expect(registration.toJson(), registrationJson());
      expect(
        WorkflowRegistration.fromJson(registration.toJson()),
        equals(registration),
      );
    });

    test('copyWith replaces deploymentName', () {
      final registration = WorkflowRegistration.fromJson(registrationJson());

      final copy = registration.copyWith(deploymentName: 'other-deployment');
      expect(copy.deploymentName, 'other-deployment');
      expect(copy.id, registration.id);
    });

    test('copyWith clears deploymentName to null via sentinel', () {
      final registration = WorkflowRegistration.fromJson(registrationJson());

      final copy = registration.copyWith(deploymentName: null);
      expect(copy.deploymentName, isNull);
    });

    test('equality and hashCode', () {
      final a = WorkflowRegistration.fromJson(registrationJson());
      final b = WorkflowRegistration.fromJson(registrationJson());
      final c = WorkflowRegistration.fromJson({
        ...registrationJson(),
        'deployment_name': 'different',
      });

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('toString contains deploymentName', () {
      final registration = WorkflowRegistration.fromJson(registrationJson());

      expect(
        registration.toString(),
        contains('deploymentName: deployment-name-1'),
      );
    });
  });
}
