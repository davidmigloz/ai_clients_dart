import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'AgentEnvironmentList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":true,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"environment_1","object":"agent.environment","type":"openai_hosted","status":"pending","files":[],"skills":[],"plugins":[]}],"first_id":"environment_1","has_more":true,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":true,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1_alternate","has_more":true,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentEnvironmentList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":true,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":false,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":true,"last_id":"environment_14","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentList.fromJson(
        jsonDecode(
              r'''{"data":[{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_2","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_3","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_4","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_5","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_6","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_7","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_8","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_9","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"ready","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_10","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"connected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_11","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"disconnected","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_12","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"suspended","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_13","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"expired","type":"self_hosted"},{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_14","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}],"first_id":"environment_1","has_more":true,"last_id":"environment_14_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentRequest.environment: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentRequest.fromJson(
        jsonDecode(
              r'''{"environment":{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"},"vault_ids":["vault_synthetic"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentRequest.fromJson(
        jsonDecode(
              r'''{"environment":{"type":"openai_hosted"},"vault_ids":["vault_synthetic"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(environment: replacement.environment);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'CreateAgentEnvironmentRequest.vaultIds: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentRequest.fromJson(
        jsonDecode(
              r'''{"environment":{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"},"vault_ids":["vault_synthetic"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentRequest.fromJson(
        jsonDecode(
              r'''{"environment":{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"},"vault_ids":["/workspace/next"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(vaultIds: replacement.vaultIds);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(vaultIds: null);
      expect(cleared.toJson().containsKey('vault_ids'), isTrue);
      expect(cleared.toJson()['vault_ids'], isNull);
      final omitted = original.copyWith(vaultIds: null, clearVaultIds: false);
      expect(omitted.toJson().containsKey('vault_ids'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(vaultIds: original.vaultIds);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(vaultIds: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.capabilityDirectories: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/next"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        capabilityDirectories: replacement.capabilityDirectories,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(capabilityDirectories: null);
      expect(cleared.toJson().containsKey('capability_directories'), isTrue);
      expect(cleared.toJson()['capability_directories'], isNull);
      final omitted = original.copyWith(
        capabilityDirectories: null,
        clearCapabilityDirectories: false,
      );
      expect(omitted.toJson().containsKey('capability_directories'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(
        capabilityDirectories: original.capabilityDirectories,
      );
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(capabilityDirectories: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.desktop: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":false},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(desktop: replacement.desktop);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(desktop: null);
      expect(cleared.toJson().containsKey('desktop'), isTrue);
      expect(cleared.toJson()['desktop'], isNull);
      final omitted = original.copyWith(desktop: null, clearDesktop: false);
      expect(omitted.toJson().containsKey('desktop'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(desktop: original.desktop);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(desktop: Object()), throwsFormatException);
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.env: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"alternate":"PRIVATE-new-metadata"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(env: replacement.env);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(env: null);
      expect(cleared.toJson().containsKey('env'), isTrue);
      expect(cleared.toJson()['env'], isNull);
      final omitted = original.copyWith(env: null, clearEnv: false);
      expect(omitted.toJson().containsKey('env'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(env: original.env);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(env: Object()), throwsFormatException);
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.environmentTemplateId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1_alternate","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        environmentTemplateId: replacement.environmentTemplateId,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(environmentTemplateId: null);
      expect(cleared.toJson().containsKey('environment_template_id'), isFalse);
      expect(
        () => original.copyWith(environmentTemplateId: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.files: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(files: replacement.files);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(files: null);
      expect(cleared.toJson().containsKey('files'), isTrue);
      expect(cleared.toJson()['files'], isNull);
      final omitted = original.copyWith(files: null, clearFiles: false);
      expect(omitted.toJson().containsKey('files'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(files: original.files);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(files: Object()), throwsFormatException);
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.network: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"enabled"},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(network: replacement.network);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(network: null);
      expect(cleared.toJson().containsKey('network'), isTrue);
      expect(cleared.toJson()['network'], isNull);
      final omitted = original.copyWith(network: null, clearNetwork: false);
      expect(omitted.toJson().containsKey('network'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(network: original.network);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(network: Object()), throwsFormatException);
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.packages: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(packages: replacement.packages);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(packages: null);
      expect(cleared.toJson().containsKey('packages'), isTrue);
      expect(cleared.toJson()['packages'], isNull);
      final omitted = original.copyWith(packages: null, clearPackages: false);
      expect(omitted.toJson().containsKey('packages'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(packages: original.packages);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(packages: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.plugins: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description_alternate","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(plugins: replacement.plugins);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(plugins: null);
      expect(cleared.toJson().containsKey('plugins'), isTrue);
      expect(cleared.toJson()['plugins'], isNull);
      final omitted = original.copyWith(plugins: null, clearPlugins: false);
      expect(omitted.toJson().containsKey('plugins'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(plugins: original.plugins);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(plugins: Object()), throwsFormatException);
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.setupCommands: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":""}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        setupCommands: replacement.setupCommands,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(setupCommands: null);
      expect(cleared.toJson().containsKey('setup_commands'), isTrue);
      expect(cleared.toJson()['setup_commands'], isNull);
      final omitted = original.copyWith(
        setupCommands: null,
        clearSetupCommands: false,
      );
      expect(omitted.toJson().containsKey('setup_commands'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(setupCommands: original.setupCommands);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(setupCommands: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentPrewarmHostedEnvironment.skills: replacement, full equality/hash and copy presence',
    () {
      final original = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentPrewarmHostedEnvironment.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"environment_template_id":"environment_template_1","files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"type":"skill_reference","skill_id":"skill_synthetic"}],"type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skills: replacement.skills);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(skills: null);
      expect(cleared.toJson().containsKey('skills'), isTrue);
      expect(cleared.toJson()['skills'], isNull);
      final omitted = original.copyWith(skills: null, clearSkills: false);
      expect(omitted.toJson().containsKey('skills'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(skills: original.skills);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(skills: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.capabilityDirectories: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/next"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        capabilityDirectories: replacement.capabilityDirectories,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(capabilityDirectories: null);
      expect(cleared.toJson().containsKey('capability_directories'), isTrue);
      expect(cleared.toJson()['capability_directories'], isNull);
      final omitted = original.copyWith(
        capabilityDirectories: null,
        clearCapabilityDirectories: false,
      );
      expect(omitted.toJson().containsKey('capability_directories'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(
        capabilityDirectories: original.capabilityDirectories,
      );
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(capabilityDirectories: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.desktop: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":false},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(desktop: replacement.desktop);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(desktop: null);
      expect(cleared.toJson().containsKey('desktop'), isTrue);
      expect(cleared.toJson()['desktop'], isNull);
      final omitted = original.copyWith(desktop: null, clearDesktop: false);
      expect(omitted.toJson().containsKey('desktop'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(desktop: original.desktop);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(desktop: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.env: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"alternate":"PRIVATE-new-metadata"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(env: replacement.env);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(env: null);
      expect(cleared.toJson().containsKey('env'), isTrue);
      expect(cleared.toJson()['env'], isNull);
      final omitted = original.copyWith(env: null, clearEnv: false);
      expect(omitted.toJson().containsKey('env'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(env: original.env);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(env: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.files: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(files: replacement.files);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(files: null);
      expect(cleared.toJson().containsKey('files'), isTrue);
      expect(cleared.toJson()['files'], isNull);
      final omitted = original.copyWith(files: null, clearFiles: false);
      expect(omitted.toJson().containsKey('files'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(files: original.files);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(files: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.name: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀_alternate","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(name: null);
      expect(cleared.toJson().containsKey('name'), isTrue);
      expect(cleared.toJson()['name'], isNull);
      final omitted = original.copyWith(name: null, clearName: false);
      expect(omitted.toJson().containsKey('name'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(name: original.name);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(name: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.network: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"enabled"},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(network: replacement.network);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(network: null);
      expect(cleared.toJson().containsKey('network'), isTrue);
      expect(cleared.toJson()['network'], isNull);
      final omitted = original.copyWith(network: null, clearNetwork: false);
      expect(omitted.toJson().containsKey('network'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(network: original.network);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(network: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.packages: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(packages: replacement.packages);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(packages: null);
      expect(cleared.toJson().containsKey('packages'), isTrue);
      expect(cleared.toJson()['packages'], isNull);
      final omitted = original.copyWith(packages: null, clearPackages: false);
      expect(omitted.toJson().containsKey('packages'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(packages: original.packages);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(packages: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.plugins: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description_alternate","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(plugins: replacement.plugins);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(plugins: null);
      expect(cleared.toJson().containsKey('plugins'), isTrue);
      expect(cleared.toJson()['plugins'], isNull);
      final omitted = original.copyWith(plugins: null, clearPlugins: false);
      expect(omitted.toJson().containsKey('plugins'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(plugins: original.plugins);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(plugins: Object()), throwsFormatException);
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.setupCommands: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":""}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        setupCommands: replacement.setupCommands,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(setupCommands: null);
      expect(cleared.toJson().containsKey('setup_commands'), isTrue);
      expect(cleared.toJson()['setup_commands'], isNull);
      final omitted = original.copyWith(
        setupCommands: null,
        clearSetupCommands: false,
      );
      expect(omitted.toJson().containsKey('setup_commands'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(setupCommands: original.setupCommands);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(setupCommands: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'CreateAgentEnvironmentTemplateRequest.skills: replacement, full equality/hash and copy presence',
    () {
      final original = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = CreateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"type":"skill_reference","skill_id":"skill_synthetic"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skills: replacement.skills);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(skills: null);
      expect(cleared.toJson().containsKey('skills'), isTrue);
      expect(cleared.toJson()['skills'], isNull);
      final omitted = original.copyWith(skills: null, clearSkills: false);
      expect(omitted.toJson().containsKey('skills'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(skills: original.skills);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(skills: Object()), throwsFormatException);
    },
  );
  test(
    'DeletedAgentEnvironmentTemplate.deleted: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedAgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"environment_template_1","object":"agent.environment.template.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedAgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"deleted":false,"id":"environment_template_1","object":"agent.environment.template.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(deleted: replacement.deleted);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'DeletedAgentEnvironmentTemplate.id: replacement, full equality/hash and copy presence',
    () {
      final original = DeletedAgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"environment_template_1","object":"agent.environment.template.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = DeletedAgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"deleted":true,"id":"environment_template_1_alternate","object":"agent.environment.template.deleted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionDesktopConfig.enabled: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionDesktopConfig.fromJson(
        jsonDecode(r'''{"enabled":true}''') as Map<String, dynamic>,
      );
      final replacement = AgentSessionDesktopConfig.fromJson(
        jsonDecode(r'''{"enabled":false}''') as Map<String, dynamic>,
      );
      final result = original.copyWith(enabled: replacement.enabled);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionDesktopResource.enabled: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionDesktopResource.fromJson(
        jsonDecode(r'''{"enabled":true}''') as Map<String, dynamic>,
      );
      final replacement = AgentSessionDesktopResource.fromJson(
        jsonDecode(r'''{"enabled":false}''') as Map<String, dynamic>,
      );
      final result = original.copyWith(enabled: replacement.enabled);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionEnvironmentPackagesConfig.npm: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEnvironmentPackagesConfig.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEnvironmentPackagesConfig.fromJson(
        jsonDecode(
              r'''{"npm":["/workspace/next"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(npm: replacement.npm);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(npm: null);
      expect(cleared.toJson().containsKey('npm'), isTrue);
      expect(cleared.toJson()['npm'], isNull);
      final omitted = original.copyWith(npm: null, clearNpm: false);
      expect(omitted.toJson().containsKey('npm'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(npm: original.npm);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(npm: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionEnvironmentPackagesConfig.python: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEnvironmentPackagesConfig.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEnvironmentPackagesConfig.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["/workspace/next"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(python: replacement.python);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(python: null);
      expect(cleared.toJson().containsKey('python'), isTrue);
      expect(cleared.toJson()['python'], isNull);
      final omitted = original.copyWith(python: null, clearPython: false);
      expect(omitted.toJson().containsKey('python'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(python: original.python);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(python: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionEnvironmentPackagesConfig.system: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEnvironmentPackagesConfig.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEnvironmentPackagesConfig.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["/workspace/next"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(system: replacement.system);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(system: null);
      expect(cleared.toJson().containsKey('system'), isTrue);
      expect(cleared.toJson()['system'], isNull);
      final omitted = original.copyWith(system: null, clearSystem: false);
      expect(omitted.toJson().containsKey('system'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(system: original.system);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(system: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionEnvironmentPackagesResource.npm: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEnvironmentPackagesResource.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEnvironmentPackagesResource.fromJson(
        jsonDecode(
              r'''{"npm":["/workspace/next"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(npm: replacement.npm);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionEnvironmentPackagesResource.python: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEnvironmentPackagesResource.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEnvironmentPackagesResource.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["/workspace/next"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(python: replacement.python);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionEnvironmentPackagesResource.system: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionEnvironmentPackagesResource.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionEnvironmentPackagesResource.fromJson(
        jsonDecode(
              r'''{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["/workspace/next"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(system: replacement.system);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplateList.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"id":"environment_template_1","name":null,"object":"agent.environment.template","created_at":0,"updated_at":0,"packages":{"python":[],"system":[],"npm":[]},"network":{"access":"enabled","allowed_domains":[]},"desktop":{"enabled":false},"capability_directories":[],"skills":[],"plugins":[],"files":[]}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplateList.firstId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1_alternate","has_more":true,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(firstId: replacement.firstId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(firstId: null);
      expect(cleared.toJson().containsKey('first_id'), isTrue);
      expect(cleared.toJson()['first_id'], isNull);
      expect(() => original.copyWith(firstId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentEnvironmentTemplateList.hasMore: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":false,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(hasMore: replacement.hasMore);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplateList.lastId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplateList.fromJson(
        jsonDecode(
              r'''{"data":[{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}],"first_id":"environment_template_1","has_more":true,"last_id":"environment_template_1_alternate","object":"list"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(lastId: replacement.lastId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(lastId: null);
      expect(cleared.toJson().containsKey('last_id'), isTrue);
      expect(cleared.toJson()['last_id'], isNull);
      expect(() => original.copyWith(lastId: Object()), throwsFormatException);
    },
  );
  test(
    'AgentEnvironmentTemplate.capabilityDirectories: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/next"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        capabilityDirectories: replacement.capabilityDirectories,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.createdAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000001,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(createdAt: replacement.createdAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.desktop: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":false},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(desktop: replacement.desktop);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.files: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(files: replacement.files);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1_alternate","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀_alternate","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(name: null);
      expect(cleared.toJson().containsKey('name'), isTrue);
      expect(cleared.toJson()['name'], isNull);
      expect(() => original.copyWith(name: Object()), throwsFormatException);
    },
  );
  test(
    'AgentEnvironmentTemplate.network: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"enabled","allowed_domains":[]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(network: replacement.network);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.packages: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"python":[],"system":[],"npm":[]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(packages: replacement.packages);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.plugins: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description_alternate","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(plugins: replacement.plugins);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.skills: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"type":"skill_reference","skill_id":"skill_synthetic","version":null}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skills: replacement.skills);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironmentTemplate.updatedAt: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000000}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironmentTemplate.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"created_at":1700000000,"desktop":{"enabled":true},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_template_1","name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"]},"object":"agent.environment.template","packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"Template café🚀","type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"updated_at":1700000001}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(updatedAt: replacement.updatedAt);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigFileId.fileId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic_alternate","path":"/workspace/private-input.txt","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(fileId: replacement.fileId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigFileId.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt_alternate","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigInline.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"U0VDT05E","path":"/workspace/private-input.txt","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileConfigInline.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileConfigInline.fromJson(
        jsonDecode(
              r'''{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt_alternate","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.fileId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic_alternate","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(fileId: replacement.fileId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1_alternate","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt_alternate","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceFileId.sizeBytes: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":1,"type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sizeBytes: replacement.sizeBytes);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        jsonDecode(
              r'''{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        jsonDecode(
              r'''{"id":"environment_1_alternate","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        jsonDecode(
              r'''{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        jsonDecode(
              r'''{"id":"environment_1","path":"/workspace/private-input.txt_alternate","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedEnvironmentFileResourceInline.sizeBytes: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        jsonDecode(
              r'''{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedEnvironmentFileResourceInline.fromJson(
        jsonDecode(
              r'''{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":1,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sizeBytes: replacement.sizeBytes);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedPluginConfigInline.description: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedPluginConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedPluginConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description_alternate","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(description: replacement.description);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedPluginConfigInline.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedPluginConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedPluginConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability_alternate","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedPluginConfigInline.source: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedPluginConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedPluginConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"U0VDT05E","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(source: replacement.source);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedPluginResourceInline.description: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedPluginResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedPluginResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description_alternate","name":"example_capability","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(description: replacement.description);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedPluginResourceInline.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedPluginResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedPluginResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability_alternate","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillConfigInline.description: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description_alternate","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(description: replacement.description);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillConfigInline.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability_alternate","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillConfigInline.source: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillConfigInline.fromJson(
        jsonDecode(
              r'''{"description":"PRIVATE-description","name":"example_capability","source":{"data":"U0VDT05E","media_type":"application/zip","type":"base64"},"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(source: replacement.source);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillConfigSkillReference.skillId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillConfigSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillConfigSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic_alternate","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skillId: replacement.skillId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillConfigSkillReference.version: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillConfigSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillConfigSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(version: replacement.version);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(version: null);
      expect(cleared.toJson().containsKey('version'), isTrue);
      expect(cleared.toJson()['version'], isNull);
      final omitted = original.copyWith(version: null, clearVersion: false);
      expect(omitted.toJson().containsKey('version'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(version: original.version);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(version: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionHostedSkillResourceInline.description: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description_alternate","name":"example_capability","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(description: replacement.description);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillResourceInline.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillResourceInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability_alternate","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillResourceSkillReference.description: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description_alternate","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(description: replacement.description);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillResourceSkillReference.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability_alternate","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillResourceSkillReference.skillId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic_alternate","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skillId: replacement.skillId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionHostedSkillResourceSkillReference.version: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionHostedSkillResourceSkillReference.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(version: replacement.version);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateFileFileId.fileId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateFileFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateFileFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic_alternate","path":"/workspace/private-input.txt","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(fileId: replacement.fileId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateFileFileId.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateFileFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateFileFileId.fromJson(
        jsonDecode(
              r'''{"file_id":"file_synthetic","path":"/workspace/private-input.txt_alternate","type":"file_id"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateFileInline.path: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateFileInline.fromJson(
        jsonDecode(
              r'''{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateFileInline.fromJson(
        jsonDecode(
              r'''{"path":"/workspace/private-input.txt_alternate","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(path: replacement.path);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateFileInline.sizeBytes: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateFileInline.fromJson(
        jsonDecode(
              r'''{"path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateFileInline.fromJson(
        jsonDecode(
              r'''{"path":"/workspace/private-input.txt","size_bytes":1,"type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(sizeBytes: replacement.sizeBytes);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateSkillInline.description: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateSkillInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"Template café🚀","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateSkillInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description_alternate","name":"Template café🚀","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(description: replacement.description);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateSkillInline.name: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateSkillInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"Template café🚀","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateSkillInline.fromJson(
        jsonDecode(
              r'''{"description":"Safe capability description","name":"Template café🚀_alternate","type":"inline"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateSkillSkillReference.skillId: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateSkillSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateSkillSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic_alternate","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skillId: replacement.skillId);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentHostedTemplateSkillSkillReference.version: replacement, full equality/hash and copy presence',
    () {
      final original = AgentHostedTemplateSkillSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentHostedTemplateSkillSkillReference.fromJson(
        jsonDecode(
              r'''{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(version: replacement.version);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(version: null);
      expect(cleared.toJson().containsKey('version'), isTrue);
      expect(cleared.toJson()['version'], isNull);
      expect(() => original.copyWith(version: Object()), throwsFormatException);
    },
  );
  test(
    'AgentSessionInlineCapabilitySourceConfigBase64.data: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionInlineCapabilitySourceConfigBase64.fromJson(
        jsonDecode(
              r'''{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionInlineCapabilitySourceConfigBase64.fromJson(
        jsonDecode(
              r'''{"data":"U0VDT05E","media_type":"application/zip","type":"base64"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(data: replacement.data);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionNetworkPolicyConfig.access: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionNetworkPolicyConfig.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionNetworkPolicyConfig.fromJson(
        jsonDecode(
              r'''{"access":"enabled","allowed_domains":["api.example.com"],"blocked_domains":[]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(access: replacement.access);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionNetworkPolicyConfig.allowedDomains: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionNetworkPolicyConfig.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionNetworkPolicyConfig.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":["/workspace/next"],"blocked_domains":[]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        allowedDomains: replacement.allowedDomains,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(allowedDomains: null);
      expect(cleared.toJson().containsKey('allowed_domains'), isTrue);
      expect(cleared.toJson()['allowed_domains'], isNull);
      final omitted = original.copyWith(
        allowedDomains: null,
        clearAllowedDomains: false,
      );
      expect(omitted.toJson().containsKey('allowed_domains'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(
        allowedDomains: original.allowedDomains,
      );
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(allowedDomains: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionNetworkPolicyConfig.blockedDomains: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionNetworkPolicyConfig.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":[],"blocked_domains":[]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionNetworkPolicyConfig.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":[],"blocked_domains":["/workspace/next"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        blockedDomains: replacement.blockedDomains,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(blockedDomains: null);
      expect(cleared.toJson().containsKey('blocked_domains'), isTrue);
      expect(cleared.toJson()['blocked_domains'], isNull);
      final omitted = original.copyWith(
        blockedDomains: null,
        clearBlockedDomains: false,
      );
      expect(omitted.toJson().containsKey('blocked_domains'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(
        blockedDomains: original.blockedDomains,
      );
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(blockedDomains: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'AgentSessionNetworkPolicyResource.access: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionNetworkPolicyResource.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":["api.example.com"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionNetworkPolicyResource.fromJson(
        jsonDecode(
              r'''{"access":"enabled","allowed_domains":["api.example.com"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(access: replacement.access);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionNetworkPolicyResource.allowedDomains: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionNetworkPolicyResource.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":["api.example.com"]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionNetworkPolicyResource.fromJson(
        jsonDecode(
              r'''{"access":"restricted","allowed_domains":["/workspace/next"]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        allowedDomains: replacement.allowedDomains,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironment.files: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(files: replacement.files);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironment.id: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1_alternate","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(id: replacement.id);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironment.plugins: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description_alternate","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(plugins: replacement.plugins);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironment.skills: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"type":"skill_reference","skill_id":"skill_synthetic","version":"latest","name":"example_capability","description":"Safe capability description"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skills: replacement.skills);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironment.status: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"pending","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(status: replacement.status);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentEnvironment.type: replacement, full equality/hash and copy presence',
    () {
      final original = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"self_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentEnvironment.fromJson(
        jsonDecode(
              r'''{"files":[{"file_id":"file_synthetic","id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"file_id"},{"id":"environment_1","path":"/workspace/private-input.txt","size_bytes":0,"type":"inline"}],"id":"environment_1","object":"agent.environment","plugins":[{"description":"Safe capability description","name":"example_capability","type":"inline"}],"skills":[{"description":"Safe capability description","name":"example_capability","type":"inline"},{"description":"Safe capability description","name":"example_capability","skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}],"status":"failed","type":"openai_hosted"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(type: replacement.type);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSetupCommandConfig.command: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSetupCommandConfig.fromJson(
        jsonDecode(
              r'''{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSetupCommandConfig.fromJson(
        jsonDecode(
              r'''{"command":"printf PRIVATE-setup-command_alternate","cwd":"/workspace"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(command: replacement.command);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
    },
  );
  test(
    'AgentSessionSetupCommandConfig.cwd: replacement, full equality/hash and copy presence',
    () {
      final original = AgentSessionSetupCommandConfig.fromJson(
        jsonDecode(
              r'''{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = AgentSessionSetupCommandConfig.fromJson(
        jsonDecode(
              r'''{"command":"printf PRIVATE-setup-command","cwd":"/workspace_alternate"}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(cwd: replacement.cwd);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(cwd: null);
      expect(cleared.toJson().containsKey('cwd'), isTrue);
      expect(cleared.toJson()['cwd'], isNull);
      final omitted = original.copyWith(cwd: null, clearCwd: false);
      expect(omitted.toJson().containsKey('cwd'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(cwd: original.cwd);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(cwd: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.capabilityDirectories: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/next"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        capabilityDirectories: replacement.capabilityDirectories,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(capabilityDirectories: null);
      expect(cleared.toJson().containsKey('capability_directories'), isTrue);
      expect(cleared.toJson()['capability_directories'], isNull);
      final omitted = original.copyWith(
        capabilityDirectories: null,
        clearCapabilityDirectories: false,
      );
      expect(omitted.toJson().containsKey('capability_directories'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(
        capabilityDirectories: original.capabilityDirectories,
      );
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(capabilityDirectories: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.desktop: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":false},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(desktop: replacement.desktop);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(desktop: null);
      expect(cleared.toJson().containsKey('desktop'), isTrue);
      expect(cleared.toJson()['desktop'], isNull);
      final omitted = original.copyWith(desktop: null, clearDesktop: false);
      expect(omitted.toJson().containsKey('desktop'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(desktop: original.desktop);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(desktop: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.env: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"alternate":"PRIVATE-new-metadata"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(env: replacement.env);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(env: null);
      expect(cleared.toJson().containsKey('env'), isTrue);
      expect(cleared.toJson()['env'], isNull);
      final omitted = original.copyWith(env: null, clearEnv: false);
      expect(omitted.toJson().containsKey('env'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(env: original.env);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(env: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.files: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(files: replacement.files);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(files: null);
      expect(cleared.toJson().containsKey('files'), isTrue);
      expect(cleared.toJson()['files'], isNull);
      final omitted = original.copyWith(files: null, clearFiles: false);
      expect(omitted.toJson().containsKey('files'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(files: original.files);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(files: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.name: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀_alternate","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(name: replacement.name);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(name: null);
      expect(cleared.toJson().containsKey('name'), isTrue);
      expect(cleared.toJson()['name'], isNull);
      final omitted = original.copyWith(name: null, clearName: false);
      expect(omitted.toJson().containsKey('name'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(name: original.name);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(name: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.network: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"enabled"},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(network: replacement.network);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(network: null);
      expect(cleared.toJson().containsKey('network'), isTrue);
      expect(cleared.toJson()['network'], isNull);
      final omitted = original.copyWith(network: null, clearNetwork: false);
      expect(omitted.toJson().containsKey('network'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(network: original.network);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(network: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.packages: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(packages: replacement.packages);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(packages: null);
      expect(cleared.toJson().containsKey('packages'), isTrue);
      expect(cleared.toJson()['packages'], isNull);
      final omitted = original.copyWith(packages: null, clearPackages: false);
      expect(omitted.toJson().containsKey('packages'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(packages: original.packages);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(packages: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.plugins: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description_alternate","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(plugins: replacement.plugins);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(plugins: null);
      expect(cleared.toJson().containsKey('plugins'), isTrue);
      expect(cleared.toJson()['plugins'], isNull);
      final omitted = original.copyWith(plugins: null, clearPlugins: false);
      expect(omitted.toJson().containsKey('plugins'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(plugins: original.plugins);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(plugins: Object()), throwsFormatException);
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.setupCommands: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":""}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(
        setupCommands: replacement.setupCommands,
      );
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(setupCommands: null);
      expect(cleared.toJson().containsKey('setup_commands'), isTrue);
      expect(cleared.toJson()['setup_commands'], isNull);
      final omitted = original.copyWith(
        setupCommands: null,
        clearSetupCommands: false,
      );
      expect(omitted.toJson().containsKey('setup_commands'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(setupCommands: original.setupCommands);
      expect(restored.toJson(), original.toJson());
      expect(
        () => original.copyWith(setupCommands: Object()),
        throwsFormatException,
      );
    },
  );
  test(
    'UpdateAgentEnvironmentTemplateRequest.skills: replacement, full equality/hash and copy presence',
    () {
      final original = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"},{"skill_id":"skill_synthetic","type":"skill_reference","version":"latest"}]}''',
            )
            as Map<String, dynamic>,
      );
      final replacement = UpdateAgentEnvironmentTemplateRequest.fromJson(
        jsonDecode(
              r'''{"capability_directories":["/workspace/capabilities"],"desktop":{"enabled":true},"env":{"APP_CONFIG":"PRIVATE-environment-value"},"files":[{"file_id":"file_synthetic","path":"/workspace/private-input.txt","type":"file_id"},{"data":"UFJJVkFURSBzeW50aGV0aWMgaW5saW5lIGZpbGUK","path":"/workspace/private-input.txt","type":"inline"}],"name":"Template café🚀","network":{"access":"restricted","allowed_domains":["api.example.com"],"blocked_domains":[]},"packages":{"npm":["lodash@4.17.21"],"python":["pytest==8.0.0"],"system":["jq"]},"plugins":[{"description":"PRIVATE-description","name":"example_capability","source":{"data":"UEsDBBQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAZXhhbXBsZV9jYXBhYmlsaXR5L1NLSUxMLm1kLS0tCm5hbWU6IGV4YW1wbGVfY2FwYWJpbGl0eQpkZXNjcmlwdGlvbjogUFJJVkFURS1kZXNjcmlwdGlvbgotLS0KU3ludGhldGljIG9mZmxpbmUgY2FwYWJpbGl0eS4KUEsDBBQAAAAAAAAAIVDU3HUTRAAAAEQAAAAsAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb257Im5hbWUiOiAiZXhhbXBsZV9jYXBhYmlsaXR5IiwgImRlc2NyaXB0aW9uIjogIlBSSVZBVEUtZGVzY3JpcHRpb24ifVBLAQIUAxQAAAAAAAAAIVB4AtYVYAAAAGAAAAAbAAAAAAAAAAAAAACAAQAAAABleGFtcGxlX2NhcGFiaWxpdHkvU0tJTEwubWRQSwECFAMUAAAAAAAAACFQ1Nx1E0QAAABEAAAALAAAAAAAAAAAAAAAgAGZAAAAZXhhbXBsZV9jYXBhYmlsaXR5Ly5jb2RleC1wbHVnaW4vcGx1Z2luLmpzb25QSwUGAAAAAAIAAgCjAAAAJwEAAAAA","media_type":"application/zip","type":"base64"},"type":"inline"}],"setup_commands":[{"command":"printf PRIVATE-setup-command","cwd":"/workspace"}],"skills":[{"type":"skill_reference","skill_id":"skill_synthetic"}]}''',
            )
            as Map<String, dynamic>,
      );
      final result = original.copyWith(skills: replacement.skills);
      expect(result.toJson(), replacement.toJson());
      expect(result, replacement);
      expect(result.hashCode, replacement.hashCode);
      expect(result, isNot(original));
      expect(original.copyWith().toJson(), original.toJson());
      final cleared = original.copyWith(skills: null);
      expect(cleared.toJson().containsKey('skills'), isTrue);
      expect(cleared.toJson()['skills'], isNull);
      final omitted = original.copyWith(skills: null, clearSkills: false);
      expect(omitted.toJson().containsKey('skills'), isFalse);
      expect(cleared.copyWith().toJson(), cleared.toJson());
      final restored = cleared.copyWith(skills: original.skills);
      expect(restored.toJson(), original.toJson());
      expect(() => original.copyWith(skills: Object()), throwsFormatException);
    },
  );
}
